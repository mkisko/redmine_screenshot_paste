require_dependency 'uploaded_screenshot'

module RedmineScreenshotPaste
  module Patches
    module ControllerPatch
      def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable
          before_filter :params_attachments_with_screenshot
        end
      end
    end

    module AttachmentPatch
      def self.included(base)
        base.send(:extend, ClassMethods)
        base.class_eval do
          class << self
            alias_method_chain :attach_files, :screenshot
          end
        end
      end
    end

    module ClassMethods
      def attach_files_with_screenshot(obj, attachments)
        if attachments.is_a?(Hash)
          attachments.each do |key, attachment|
            if key.start_with?('screenshot') && attachment.is_a?(Hash)
              file = UploadedScreenshot.new(attachment.delete('content'),
                                            attachment.delete('name'))
              attachment['file'] = file
            end
          end
        end
        attach_files_without_screenshot(obj, attachments)
      end
    end

    module InstanceMethods
      def params_attachments_with_screenshot
        attachments = params[:attachments]
        if attachments.is_a?(Hash)
          attachments.each do |key, attachment|
            if key.start_with?('screenshot') && attachment.is_a?(Hash)
              file = UploadedScreenshot.new(attachment.delete('content'),
                                            attachment.delete('name'))
              attachment['file'] = file
            end
          end
        end
      end
    end
  end
end
