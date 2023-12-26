# frozen_string_literal: true

module Decidim
  class ProposalsSliderController < Decidim::ApplicationController
    include Decidim::FilterResource
    include Decidim::TranslatableAttributes
    include Decidim::Core::Engine.routes.url_helpers
    include Decidim::ComponentPathHelper
    include Decidim::SanitizeHelper
    include Decidim::HomepageProposals::HomepageProposalsHelper

    def refresh_proposals
      render json: { categories: categories_filter.pluck(:id), scopes: scopes_filter.collect(&:last), slides: build_proposals_api }
    end

    private

    def build_proposals_api
      return component_url unless glanced_proposals.any?

      glanced_proposals.flat_map do |proposal|
        {
          id: proposal.id,

          title: translated_attribute(proposal.title).truncate(30),
          body: decidim_sanitize(translated_attribute(proposal.body), strip_tags: true).truncate(150),
          url: proposal_path(proposal),
          image: image_for(proposal),
          state: proposal.state,
          category: proposal.category ? cell("decidim/tags", proposal).render(:category).strip.html_safe : "",
          scope: proposal.scope ? cell("decidim/tags", proposal).render(:scope).strip.html_safe : ""
        }
      end
    end

    def glanced_proposals
      if params[:filter].present?
        category = Decidim::Category.find(params.dig(:filter, :category_id)) if params.dig(:filter, :category_id).present?
        scopes = Decidim::Scope.find(params.dig(:filter, :scope_id)).descendants if params.dig(:filter, :scope_id).present?
      end

      @glanced_proposals ||= Decidim::Proposals::Proposal.published
                                                         .where(component: params.dig(:filter, :component_id))
                                                         .where(filter_by_scopes(scopes))
                                                         .select do |proposal|
                                                           if category.present?
                                                             proposal.category == category
                                                           else
                                                             true
                                                           end
                                                         end
                                                         .sample(12)
    end

    def filter_by_scopes(scopes)
      { scope: scopes } if scopes.present?
    end

    def proposal_path(proposal)
      Decidim::ResourceLocatorPresenter.new(proposal).path
    end

    def image_for(proposal)
      return view_context.image_pack_url("media/images/slider_proposal_image.jpeg") unless proposal.attachments.select(&:image?).any?

      proposal.attachments.select(&:image?).first&.thumbnail_url
    end

    def component_url
      return { url: "/" } if params.dig(:filter, :component_id).blank?

      begin
        { url: main_component_path(Decidim::Component.find(params.dig(:filter, :component_id))) }
      rescue ActiveRecord::RecordNotFound
        { url: "/" }
      end
    end

    def scopes_filter
      options = []
      root = selected_component.collect(&:scope).collect(&:blank?).any?

      scopes = if root
                 current_organization.scopes.top_level
               else
                 selected_component.collect(&:scope).uniq
               end

      scopes.each do |scope|
        options_for_scope(options, scope, 0)
      end
      options
    end
  end
end
