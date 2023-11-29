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
        include Decidim::CategoriesHelper
        include Decidim::HomepageProposals::HomepageProposalsHelper

        def default_linked_component_path
          main_component_path(Decidim::Component.find(selected_component_id))
        rescue ActiveRecord::RecordNotFound
          root_path
        end

        def options_for_default_component
          options = linked_components.map do |component|
            ["#{translated_attribute(component.name)} (#{translated_attribute(component.participatory_space.title)})", component.id]
          end

          options_for_select(options, selected: selected_component_id)
        end

        def default_filter_params
          {
            scope_id: nil,
            category_id: nil,
            component_id: nil
          }
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
      end
    end
  end
end
