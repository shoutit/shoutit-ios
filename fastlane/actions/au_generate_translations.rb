module Fastlane
  module Actions

    class AuGenerateTranslationsAction < Action
      def self.run(params)
        
        Helper.log.info "Generating localization for project #{params[:project_file_path]}"
        
        command = "cd #{params[:export_dir]}"
        Fastlane::Actions.sh command, log: true
        
        command = "git reset HEAD --hard && git pull origin master"
        Fastlane::Actions.sh command, log: true
        
        command = "cd .."
        Fastlane::Actions.sh command, log: true
        
        params[:languages].strip.split(" ").each do |lang|
          Helper.log.info "Generating localization file for: #{lang}"
        
          command = "xcodebuild -exportLocalizations -localizationPath #{params[:export_dir]} -project #{params[:project_file_path]} -exportLanguage #{lang}"
          Fastlane::Actions.sh command, log: true
          
        end

        command = "cd #{params[:export_dir]} && git add -A && git commit -am 'translations update' && git push origin HEAD:master"
        Fastlane::Actions.sh command, log: true
        
        Helper.log.info "Localization files exported to #{params[:export_dir]}"

      end

      def self.description
        "Generate xliff files and commit them into external repository"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :languages,
                                       env_name: "AU_SUPPORTED_LANGUAGES",
                                       description: "Languages to export localizations",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :export_dir,
                                      env_name: "AU_EXPORT_XLIFF_DIRECTORY",
                                      description: "Export localizations directory",
                                      optional: false),
          FastlaneCore::ConfigItem.new(key: :project_file_path,
                                      env_name: "AU_EXPORT_XLIFF_PROJECT_FILE_PATH",
                                      description: "Export Project file path",
                                      optional: false)
        ]
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