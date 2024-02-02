import GlideItem from "./GlideItem";

export default class Proposal extends GlideItem {
    constructor(obj) {
        super();
        this.title = obj.title;
        this.body = obj.body;
        this.image = obj.image;
        this.url = obj.url;
        this.state = obj.state || 'not answered' ;
        this.stateI18n = obj.state_i18n;
        this.color = obj.state_css_class;
        this.scope = obj.scope;
        this.category = obj.category;
    }

    getTagsTemplate() {
        return `<ul class="tags tags--proposal">
    ${this.category}
    ${this.scope}
</ul>`
    }

    render() {
        return `<div class="column glide__slide">
<div class="card card--proposal card--stack">
    <a href="${this.url}">
      <div class="proposal-glance card--header">
        <img src="${this.image}" class="proposal-glance__img" alt="slider_img">
      </div>
    </a>
    <div class="card--process__small text-center padding-1">
        <span class="${this.color} card__text--status status_slider"> ${this.stateI18n} </span>
        <a href="${this.url}"><h3 class="proposal-glance card__title">${this.title}</h3></a>
        
        <div class="card__text--paragraph padding-top-1">
            ${this.getTagsTemplate()}
            ${this.body}
        </div>
    </div>
    <div class="card__button align-bottom text-center padding-top-1">
        <a href="${this.url}">
            <span class="button small button--secondary">Visit</span>
        </a>
    </div>
  </div>
</div>`
    }

}
