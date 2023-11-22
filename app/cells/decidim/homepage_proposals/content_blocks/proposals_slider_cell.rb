# frozen_string_literal: true

module Decidim
  module HomepageProposals
    module ContentBlocks
      class ProposalsSliderCell < Decidim::ViewModel
        attr_accessor :glanced_proposals

        include Cell::ViewModel::Partial
        include Core::Engine.routes.url_helpers
        include Decidim::IconHelper
        include ActionView::Helpers::FormOptionsHelper
        include Decidim::FiltersHelper
        include Decidim::FilterResource
        include Decidim::ComponentPathHelper

        def default_linked_component_path
          main_component_path(Decidim::Component.find(selected_component_id))
        rescue ActiveRecord::RecordNotFound
          root_path
        end

        def content_block_settings
          @content_block_settings ||= Decidim::ContentBlock.find_by(
            manifest_name: "proposals_slider",
            organization: current_organization
          ).settings
        end

        def options_for_default_component
          options = linked_components.map do |component|
            ["#{translated_attribute(component.name)} (#{translated_attribute(component.participatory_space.title)})", component.id]
          end

          options_for_select(options, selected: selected_component_id)
        end

        def linked_components
          @linked_components ||= Decidim::Component.where(id: content_block_settings.linked_components_id.compact)
        end

        def default_filter_params
          {
            scope_id: nil,
            category_id: nil,
            component_id: nil
          }
        end

        def categories_filter
          @categories_filter ||= Decidim::Category.where(id: linked_components.map(&:categories).flatten).map { |category| [translated_attribute(category.name), category.id] }
        end

        def selected_component_id
          @selected_component_id ||= params.dig(:filter, :component_id) || content_block_settings.default_linked_component
        end

        def scopes_filter
          options = []
          root = linked_components.collect(&:scope).collect(&:blank?).any?

          scopes = if root
                     current_organization.scopes.top_level
                   else
                     linked_components.collect(&:scope).uniq
                   end

          scopes.each do |scope|
            options_for_scope(options, scope, 0)
          end
          options
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
end
