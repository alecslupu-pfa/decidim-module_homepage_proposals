# frozen_string_literal: true

module Decidim
  module HomepageProposals
    module HomepageProposalsHelper
      def content_block_settings
        @content_block_settings ||= Decidim::ContentBlock.find_by(
          manifest_name: "proposals_slider",
          organization: current_organization
        ).settings
      end

      def selected_component
        @selected_component ||= Decidim::Component.where(id: selected_component_id)
      end

      def selected_component_id
        @selected_component_id ||= params.dig(:filter, :component_id) || content_block_settings.default_linked_component
      end

      def linked_components
        @linked_components ||= Decidim::Component.where(id: content_block_settings.linked_components_id.compact)
      end

      def categories_filter
        @categories_filter ||= Decidim::Category.where(id: selected_component.map(&:categories).flatten)
      end

      def options_for_scope(options, scope, level = 0)
        options << [("--" * level) + translated_attribute(scope.name), scope.id]

        scope.children.each do |child|
          options_for_scope(options, child, level + 1)
        end
      end
    end
  end
end
