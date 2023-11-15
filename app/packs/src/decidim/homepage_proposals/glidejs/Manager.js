import FormFilterComponents from "src/decidim/form_filter.js";
import GlideBuilder from "../glideBuilder";
import GlideItem from "./glideItems/GlideItem";
import Proposal from "./glideItems/Proposal";
import NotFound from "./glideItems/NotFound";


// Manager communicates with API and build the HTML for the Glide.js carousel
// Example :
// let manager = new Manager($proposalsSlider, $proposalsGlideItems, $glideBullets, $formFilter)
// manager.start().then(() => manager.glide.mount())
//
// @return - Instance of Manager
export default class Manager {
    constructor($proposalsSlider, $proposalsGlideItems, $glideBullets, $formFilter) {
        this.$proposalSlider = $proposalsSlider;
        this.$proposalsGlideItems = $proposalsGlideItems;
        this.formFilterComponent = new FormFilterComponents($formFilter);
        this.$loading = this.$proposalSlider.find(".loading");
    }

    // @return String - API URL with filter params
    APIUrl() {
        return '/proposals_slider/refresh_proposals' + this.filterURIParams();
    }

    // @return String - Filter params query string
    filterURIParams() {
        return this.formFilterComponent._currentStateAndPath()[0];
    }

    // Clears Glide carousel and display loader
    // @return void
    startLoading() {
        let height = $(".glide__slides").css("height");
        this.clearGlideItems();
        this.$loading.css("height", height);
        this.$loading.show();
    }

    // Hide loader
    // @return void
    endLoading() {
        this.$loading.hide();
    }

    // Clears glide items and glide bullets
    // @return void
    clearGlideItems() {
        this.$proposalsGlideItems.empty();
        $(".glide__bullet.glide__bullet_idx").remove()
    }

    // We must disable existing glide carousel before refresh
    // @return void
    disableGlide() {
        if (this.glide !== undefined) {
            this.glide.disable()
        }
    }

    // Send request to API and create items received in Glide.js carousel
    // @return this.glide
    start() {
        this.startLoading();
        this.disableGlide()

        $.get(this.APIUrl())
            .done((res) => {
                this.generateGlides(res)
            })
            .fail(() => {
                this.generateGlides([])
            })
            .always((res) => {
                let length = res.length || 0;
                if (length < GlideBuilder.defaultPervView()){
                    length = GlideBuilder.defaultPervView();
                }
                this.glide = new GlideBuilder('.glide', 'carousel', length);

                if (res.length === undefined || res.length <= 1 || res.status === 500) {
                    this.glide.disable()
                }
                this.endLoading();

                this.glide.mount()
            })
    }

    // Creates Glide Items
    // @return void
    generateGlides(res) {
        if (res.url) {
            this.createProposalsNotFound(res.url);
            return;
        }

        this.createProposals(res)
    }

    // Create Glide Items with:
    // - A Not Found GlideItem
    // - 3 placeholders
    // @return void
    createProposalsNotFound(url) {
        const notFoundGlide = new NotFound(url)
        this.$proposalsGlideItems.append(notFoundGlide.render())
        $(".glide__bullets > .glide__bullet:last").before(notFoundGlide.bullet(0));

        for (let i = 0; i < GlideBuilder.defaultPervView() - 1; i++) {
            this.$proposalsGlideItems.append(notFoundGlide.placeholder());
        }
    }

    // Create Glide Items proposals, if proposals length is smaller than GlideBuilder.pervView() (default: 4)
    // Then it creates placeholders until reaching 4 Glide Items
    // @return void
    createProposals(proposals) {
        for (let i = 0; i < proposals.length; i++) {
            let proposalGlide = new Proposal(proposals[i])
            this.$proposalsGlideItems.append(proposalGlide.render());
            $(".glide__bullets > .glide__bullet:last").before(proposalGlide.bullet(i));
        }

        if (proposals.length < GlideBuilder.defaultPervView()) {
            const notFoundGlide = new NotFound("")
            for (let i = 0; i < (GlideBuilder.defaultPervView() - proposals.length); i++) {
                this.$proposalsGlideItems.append(notFoundGlide.placeholder());
            }
        }
    }
}
