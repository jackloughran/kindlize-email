require 'kindlize-email/version'
require 'nokogiri'
require 'mail'
require 'base64'
require 'down'
require 'cgi'

module EmlToHTML
  class Error < StandardError; end

  class Doer
    ACCEPTABLE_TAGS = %w[blockquote br h1 h2 h3 h4 h5 h6 ol ul li p hr i em b a]

    def initialize(file_path)
      @base = Nokogiri::HTML::Document.parse <<-EOHTML
        <html>
          <head>
            <title></title>
            <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
          </head>
          <body>
          </body>
        </html>
      EOHTML
      @working_dir = File.dirname(file_path)

      if File.extname(file_path) == '.html'
        @doc = Nokogiri::HTML(File.read(file_path, encoding: 'UTF-8'))
        @subject = file_path
      else
        message = Mail.new(File.read(file_path, encoding: 'UTF-8'))
        @doc = Nokogiri::HTML(body_html(message))
        @subject = message.subject
      end
    end

    def process
      @base.css('title').first.content = clean_subject(@subject)

      Dir.mkdir('out') unless Dir.exist?('out')

      @base.css('body').first.add_child(strip(@doc))

      File.open('out/out.html', 'w:UTF-8') { |f| f.write(@base.to_html) }
    end

    private

    def clean_subject(subject)
      subject.delete_prefix('Fwd: ')
    end

    def body_html(message)
      # emails from wordpress seem to use \r\n, but other emails don't
      fixed_message_body = message.body.decoded.gsub(/\r\n/, "\n")
      body_section_with_transfer_encoding = fixed_message_body.partition(%r{content-type: *text/html.*charset=utf-8\n}i).last
      base64_encoded_body = body_section_with_transfer_encoding.partition("base64\n\n").last.partition("\n-----------------------").first

      return Base64.decode64(base64_encoded_body).force_encoding('UTF-8') unless base64_encoded_body.empty?

      body_section_with_transfer_encoding.partition(/content-transfer-encoding: *quoted-printable\n\n/i).last.partition("\n\n------").first.force_encoding('UTF-8')
    end

    def strip(node)
      if node.name == 'img' && !node['src'].include?('pixel.wp.com')
        file_name = "#{image_counter}#{File.extname(node['src'])}"
        destination = "out/#{file_name}"
        if node['src'].start_with?('http')
          Down.download(node['src'], destination: destination)
        else
          `cp "#{@working_dir}/#{CGI.unescape(node['src'])}" "#{destination}"`
        end
        node['src'] = file_name
        node['srcset'] = nil
        return node
      end

      return node if node.name == 'text' || (ACCEPTABLE_TAGS.include?(node.name) && node.children.empty?)

      return strip(node.child) if node.children.length == 1 && !ACCEPTABLE_TAGS.include?(node.name)

      new_node = if ACCEPTABLE_TAGS.include?(node.name)
                   node
                 else
                   Nokogiri::XML::Node.new('span', @doc)
                 end

      return new_node if node.children.empty?

      new_node.children = Nokogiri::XML::NodeSet.new(@doc, node.children.map { |child| strip(child) })

      new_node
    end

    def image_counter
      @image_counter = @image_counter ? @image_counter + 1 : 1
    end
  end
end
