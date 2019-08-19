Onebox = Onebox

module Onebox
  module Engine
    class ScratchOnebox
      include Engine
      include LayoutSupport
      include HTML


      matches_regexp(/^https?:\/\/scratch.mit.edu\/.+$/)
      always_https

      def to_html_iframe_and_instructions

        <<-HTML
        <h2><a href="#{data[:url]}">#{data[:title]} (by #{data[:username]})</a></h2>
        <div style="display:flex">
          <div style="min-width:485px">
            <iframe src="https://scratch.mit.edu/projects/#{data[:project_id]}/embed" 
              allowtransparency="true" width="485" height="402" 
              frameborder="0" scrolling="no" allowfullscreen>
            </iframe>
          </div>
          <div style="margin:20px;">
            <p><b>Instructions</b></p>
            <p>#{data[:instructions]}</p>
            <p><b>Notes and credits</b></p>
            <p>#{data[:description]}</p>
            <p><b>See on Scratch</b></p>
            <p><a href="#{data[:url]}">#{data[:url]}</p>
          </div>
        </div>
        HTML
      end

      def to_html_iframe_only

        <<-HTML
        <h2><a href="#{data[:url]}">#{data[:title]} (by #{data[:username]})</a></h2>
        <iframe src="https://scratch.mit.edu/projects/#{data[:project_id]}/embed" 
           allowtransparency="true" width="485" height="402" 
           frameborder="0" scrolling="no" allowfullscreen>
        </iframe>
        HTML
      end

      def to_html_static

        <<-HTML
        <h2><a href="#{data[:url]}" target="_blank">#{data[:title]} (by #{data[:username]})</a></h2>
        <a href="#{data[:url]}" target="_blank"><img src="#{data[:image_url]}"/></a>
        HTML

      end

      def to_html
        return to_html_static
      end

      def placeholder_html
        return to_html_static
      end

      def data

        if (matches = @url.match /(?:^https?:\/\/scratch.mit.edu\/projects\/)([0-9]+)/)
          id = matches[1]
        end

        api_url = "https://api.scratch.mit.edu/projects/" + id
        response = Onebox::Helpers.fetch_response(api_url)
        scratch_project = Onebox::Oembed.new(response)

        if (matches = scratch_project.author.to_s.match /:username=&gt;"([^"]+)"/)
          username = matches[1]
        end
        
        {
          url: @url,
          project_id: id, 
          username: username,
          title: scratch_project.title, 
          image_url: scratch_project.image,
          instructions: scratch_project.instructions,
          description: scratch_project.description
        }
      end
    end
  end
end