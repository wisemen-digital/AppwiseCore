#!/usr/bin/env ruby

module Fastlane
  module Actions
    class SentryAutoSetCommitsAction < Action
      def self.run(params)
        tag_hash = Actions::last_git_tag_hash
        tag_name = Actions::last_git_tag_name
        last_commit = Actions::last_git_commit_dict
        repo = %x{git config --get remote.origin.url}.chomp[/.+@.+?[\/:](.+)\.git/, 1]

        # check if we need the commits between 2 tags, or just since the last tag
        if tag_hash.empty?
          first_commit = %x{git rev-list --max-parents=0 HEAD}.chomp
          commits = "#{first_commit}..#{last_commit[:commit_hash]}"
        elsif last_commit[:commit_hash] == tag_hash
          tags = %x{git show-ref --tags -d | grep "\\^{}" | tail -n 2 | cut -d' ' -f1}.split("\n")
          commits = "#{tags[0]}..#{tags[1]}"
        else
          commits = "#{tag_hash}..#{last_commit[:commit_hash]}"
        end

        # clear then set commits
        begin
          params[:clear] = true
          Actions::SentrySetCommitsAction.run(params)
        rescue
          UI.message "Failed to clear commits"
        end

        params[:clear] = false
        params[:commit] = "#{repo}@#{commits}"
        Actions::SentrySetCommitsAction.run(params)
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Set commits of a release"
      end

      def self.details
        [
          "This action allows you to automatically set commits in a release for a project on Sentry.",
          "See https://docs.sentry.io/cli/releases/#sentry-cli-commit-integration for more information."
        ].join(" ")
      end

      def self.available_options
        Actions::SentrySetCommitsAction.available_options + [
          FastlaneCore::ConfigItem.new(key: :project,
                                   env_name: "PROJECT",
                                description: "Project to export localizations from",
                                   optional: true,
                                       type: String)
        ]
      end

      def self.return_value
        nil
      end

      def self.authors
        ["djbe"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
