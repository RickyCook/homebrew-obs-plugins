#!/opt/homebrew/Library/Homebrew/vendor/portable-ruby/current/bin/ruby
require 'logger'
require 'net/http'
require 'uri'
require 'nokogiri'
require 'parser/current'
require 'unparser'
require 'digest/sha2'
require 'json'

class Download
  attr_reader :url

  def initialize(url, logger, response: nil, follow_redirects: false)
    @url = URI(url)
    @logger = logger
    @response = response
    @follow_redirects = follow_redirects
  end
  
  def response
    return unless @url
    @response ||= Net::HTTP.get_response(@url)
    @logger.debug("Got response: #{@response}")
    if @follow_redirects
      case @response
      when Net::HTTPRedirection
        @url = URI(@response['Location'])
        @logger.debug("Following redirect to #{@url}")
        @response = nil
        return response
      end
    end
    @response
  rescue URI::InvalidURIError => e
    @logger.error("Invalid URL: #{e.message}")
    nil
  rescue Net::HTTPError => e
    @logger.error("HTTP Error: #{e.message}")
    nil
  end
end

class Page < Download
  def doc
    @doc ||= Nokogiri::HTML(response.body)
  end
  def json
    @json ||= JSON.parse(response.body, symbolize_names: true)
  end
end

module DownloadPageMixin
  def generate_macos_download
    all_downloads = downloads
    return nil unless all_downloads
    all_downloads = all_downloads.map do |d|
      score = 0
      fn = d[:filename]
      score += 1 if fn.include?('macos')
      score += 1 if fn.end_with?('.pkg')
      score += 1 if fn.include?('universal')
      d.merge({ score: score })
    end
    all_downloads = all_downloads.sort { |l, r| l[:score] <=> r[:score]}
    all_downloads[-1]
  end
  def macos_download
    @macos_download ||= generate_macos_download
  end
  def macos_file
    @macos_file ||= Download.new(macos_download[:uri], @logger, follow_redirects: true)
  end
end

class ObsDownloadPage < Page
  attr_reader :homepage

  include DownloadPageMixin

  def initialize(homepage, logger, response: nil)
    super(URI("#{homepage}/download"), logger, response: response)
    @homepage = homepage
  end

  def downloads
    return nil unless doc
    base_uri = URI(@homepage)
    downloads = doc.css('.block-row').map do |row|
      content_row = row.css('.contentRow-main').first
      {
        filename: content_row.css('.contentRow-title').text.strip,
        uri: URI.join(base_uri, row.css('a.button--icon--download').first['href']),
      }
    end
    @logger.debug("Found downloads: #{downloads.map { |d| d[:filename] }}")
    downloads
  end
end
class GitHubDownloadPage < Page
  attr_reader :path_info, :original_uri

  include DownloadPageMixin

  class << self
    def path_info(uri)
      parts = uri.path.split('/')
      case parts[3]
      when 'releases'
        return {
          owner: parts[1],
          repo: parts[2],
        }
      else
        throw Error.new("Unknown GitHub path: #{@url.path}")
      end
    end
  end

  def initialize(uri, logger, response: nil)
    @path_info = GitHubDownloadPage.path_info(uri)
    super(
      URI("https://api.github.com/repos/#{path_info[:owner]}/#{path_info[:repo]}/releases/latest"),
      logger,
      follow_redirects: true,
    )
    @original_uri = uri
  end

  def parse_digest(asset)
    return unless asset[:digest]
    digest = asset[:digest].split(':')
    return unless digest[0] == 'sha256'
    digest[1]
  end

  def downloads
    return nil unless json
    downloads = json[:assets].map do |asset|
      {
        filename: asset[:name],
        uri: URI(asset[:browser_download_url]),
        sha256: parse_digest(asset),
      }
    end
    @logger.debug("Found downloads: #{downloads.map { |d| d[:filename] }}")
    downloads
  end
end

class ObsDownloadRequest < Download
  attr_reader :homepage

  def initialize(homepage, logger)
    super(URI("#{homepage}/download"), logger)
    @homepage = homepage
  end

  def page
    resp = response
    return unless resp

    case resp
    when Net::HTTPSuccess
      @logger.debug("Page is a ObsDownloadPage: #{resp.inspect}")
      return ObsDownloadPage.new(@homepage, @logger, response: resp)
    when Net::HTTPRedirection
      location = URI(resp['Location'])
      case location.hostname
      when 'github.com'
        @logger.debug("Page is a GithubDownloadPage: #{resp.inspect}")
        return GitHubDownloadPage.new(location, @logger, response: resp)
      else
        throw new Error("Unknown hostname in redirect: #{location.hostname}")
      end
    end
  end
end

class CaskFile
  attr_reader :path

  def initialize(path, logger)
    @path = path
    @content = nil
    @ast = nil
    @logger = logger
  end
  
  def content
    @content ||= File.read(@path)
  end

  def ast
    @ast ||= Parser::CurrentRuby.parse(content)
  rescue Parser::SyntaxError => e
    @logger.error("Syntax error in #{@path}: #{e.message}")
    nil
  end

  def check_class_node(node)
    return false unless node.type == :class
    node.children.any? { |c| c.type == :const && c.children.include?(:Formula) }
  end

  def class_node
    return ast if check_class_node(ast)
    if ast.type == :begin
      ast.children.find { |node| check_class_node(node) }
    end
  end

  def find_value(key)
    return nil unless class_node
    class_body = class_node.children.find { |c| c.type == :begin }
    return nil unless class_body
    send_node = class_body.children.find { |c| c.type == :send && c.children.include?(key) }
    return nil unless send_node
    str_node = send_node.children.last
    return nil unless str_node&.type == :str
    str_node.children.first
  end

  def update_value(key, new_value)
    return unless class_node

    class_body = class_node.children.find { |c| c.type == :begin }
    return unless class_body

    new_str_node = Parser::AST::Node.new(:str, [new_value])
    new_send_node = Parser::AST::Node.new(:send, [nil, key, new_str_node])

    new_children = class_body.children.map do |child|
      if child.type == :send && child.children[1] == key
        new_send_node
      else
        child
      end
    end

    new_body = Parser::AST::Node.new(:begin, new_children)
    new_class = Parser::AST::Node.new(:class,
      [class_node.children[0], class_node.children[1], new_body])

    @ast = if ast.type == :begin
      Parser::AST::Node.new(:begin,
        ast.children.map { |c| c == class_node ? new_class : c })
    else
      new_class
    end
  end

  def update_ast_and_write
    return unless macos_download_url
    return unless macos_download_sha256
    return unless latest_version

    update_value(:url, macos_download_url)
    update_value(:sha256, macos_download_sha256)
    update_value(:version, latest_version)

    new_content = Unparser.unparse(@ast)
    @logger.info("Writing updated content to #{@path}")
    File.write(@path, new_content)
  end

  def url
    find_value(:url)
  end

  def desc
    find_value(:desc)
  end

  def homepage
    find_value(:homepage)
  end

  def version
    find_value(:version)
  end

  def homepage_page
    @homepage_page ||= Page.new(homepage, @logger)
  end

  def download_page
    @download_page ||= ObsDownloadRequest.new(homepage, @logger).page
  end

  def macos_download_url
    return unless download_page.macos_download
    return unless download_page.macos_download[:uri]
    "#{download_page.macos_download[:uri]}"
  end
  def macos_download_content
    response = download_page.macos_file.response
    return unless response
    unless response.is_a?(Net::HTTPSuccess)
      @logger.error("Download failed: #{response.code} #{response.message}")
      return nil
    end

    response.body
  end

  def macos_download_sha256
    if download_page.macos_download && download_page.macos_download[:sha256]
      return download_page.macos_download[:sha256]
    end
    @macos_download_sha256 ||= generate_macos_download_sha256
  end

  def generate_macos_download_sha256
    content = macos_download_content
    return unless content

    Digest::SHA256.hexdigest(content)
  end

  def latest_version
    return unless homepage_page
    return unless homepage_page.doc
    homepage_page.doc.css('.p-title .u-muted').first.text.strip
  end
end

class Args
  attr_reader :argv, :glob, :verbose, :exit_code, :help

  def initialize(argv)
    @argv = argv
    @glob = '*.rb'
    @verbose = false
    @exit_code = nil
    @help = false
  end

  def print_help
    puts "usage: update.rb [OPTIONS]"
    puts ""
    puts "OPTIONS:"
    puts "    -g, --glob"
    puts "        Glob pattern to use when filtering for formula files"
    puts "        Default: *.rb"
    puts "    -v, --verbose"
    puts "        Verbose logging"
    puts "    -h, --help"
    puts "        Prints this help message"
  end

  def parse
    argv_copy = argv.clone
    until argv_copy.empty?
      arg = argv_copy.shift
      case arg
      when '-g', '--glob'
        @glob = argv_copy.shift
      when '-v', '--verbose'
        @verbose = true
      when '-h', '--help'
        @help = true
        @exit_code = 0
      else
        puts "unrecognized option: #{arg}"
        @help = true
        @exit_code = 1
        return
      end
    end
    nil
  end
end

args = Args.new(ARGV)
args.parse
args.print_help if args.help
exit(args.exit_code) if args.exit_code != nil

logger = Logger.new(STDOUT)
logger.level = args.verbose ? Logger::DEBUG : Logger::INFO

formula_files = Dir.glob(File.join(File.dirname(__FILE__), '..', args.glob))
formula_files.each do |file|
  logger.info("Loading formula file: #{File.basename(file)}")
  cask = CaskFile.new(file, logger)
  logger.info("Latest version: #{cask.latest_version}")
  logger.info("URL: #{cask.macos_download_url}")
  cask.update_ast_and_write
end
