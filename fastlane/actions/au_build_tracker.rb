module Fastlane
  module Actions

    class AuBuildTrackerAction < Action
      def self.run(params)
        require 'httparty'
        require 'uri'
        
        uri = URI.parse("BUILD_TRACKER_HOST")
       
        response = HTTParty.post(uri, { body: { 'build' =>
          { 'application_name' => params[:app_name],
                   'build_name' => params[:build_name],
                   'build_number' => params[:build_number],
                   'fabric_url' => params[:download_url]
          }
        }})
        
        Helper.log.info "Posting new build info to Appunite Build Tracker with data: AppName: #{params[:app_name]} BuildName:  #{params[:build_name]} BuildNumber:  #{params[:build_number]} DownloadURL:  #{params[:download_url]}"
        
        check_response_code(response)
      end

      def self.description
        "Generate short artifact download link"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :build_number,
                                       env_name: "AU_BUILD_NUMBER",
                                       description: "Build Number",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :build_name,
                                       env_name: "AU_BUILD_NAME",
                                       description: "Visible Build Name",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :app_name,
                                       env_name: "AU_APP_NAME",
                                       description: "Visible Aplication Name in Build Tracker",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :download_url,
                                       env_name: "AU_DOWNLOAD_URL",
                                       description: "Download url",
                                       optional: true),
        ]
      end

      def self.check_response_code(response)
        case response.code.to_i
          when 200, 204, 201, 400
            if response.code.to_i == 400
              Helper.log.info "Build with this number already exist in build tracker. Please make sure that you try to build correct commit"
            end
            
          else
            raise "Unexpected #{response.code} with response: #{response.body}".red
          end
      end
            
      def self.authors
        ["piotrbernad"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
