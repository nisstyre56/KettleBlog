<app>
  <div class="app-body">
    <div
      style={
              {
                "opacity" : showBorder ? "0.8" : "1",
                "background-color" : showBorder ? "white" : "white"
              }
            }
      class="header"
    >
    <div class="container">
      <div class="columns">
        <div class="col-2">
          <section
            class="text-center nav navbar centered navbar-section header-social"
            style={
              {
              "margin-left" : "5px",
              "margin-right" : "5px",
              "float" : "left"
              }
            }
          >
            <githubsocial
              link="https://github.com/weskerfoot"
            >
            </githubsocial>
        </div>
        <div class="col-8">
          <section
            style={{"margin-top" : page !== "posts" ? "15px" : "5px"}}
            class="text-center nav navbar centered navbar-section"
          >
            <h3 class="blog-title">
              { currentPage }
            </h3>
          </section>
        </div>
        <div class="col-2">
          <section
            class="text-center nav navbar centered navbar-section header-social"
            style={
              {
              "margin-left" : "5px",
              "margin-right" : "5px",
              "float" : "right"
              }
            }
          >
            <headersocial
              link="https://twitter.com/weskerfoot"
            >
            </headersocial>
          </section>
        </div>
      </div>
    </div>
  </div>
    <div id="menu"
      class={"show-md show-sm show-xs navigate-small dropdown dropdown-right " + (menuActive ? "active" : "")}
    >
      <button
        onclick={menuOn}
        class="mobile-navigate btn btn-link navigate-item dropdown-toggle branded"
        tabindex="0"
      >
        <i class="bar-menu fa fa-bars" aria-hidden="true"></i>
      </button>
      <!-- menu component -->
      <ul
        show={menuActive}
        class="mobile-menu tab tab-block menu"
      >
        <li
          each="{page in ['browse', 'projects', 'links', 'about']}"
          class={"navigate-tab tab-item " + (parent.active.get(page) ? "active" : "")}
          data-is="navtab"
          active={parent.active.get(page)}
          to={parent.to(page)}
          title={page}
          onclick={parent.menuOff}
        >
        </li>
      </ul>
    </div>

    <ul class="hide-md hide-sm hide-xs navigate tab tab-block">
      <li
        each="{page in ['browse', 'projects', 'links', 'about']}"
        class={"navigate-tab tab-item " + (parent.active.get(page) ? "active" : "")}
        data-is="navtab"
        active={parent.active.get(page)}
        to={parent.to(page)}
        title={page}
      >
      </li>
    </ul>
    <div class="projects-content">
      <projects
        class=""
        if={active.get("projects")}
        state={state}
      >
      </projects>
    </div>

    <div class="content">
      <postsview
        state={state}
        if={active.get("posts")}
        ref="postsview"
      >
      </postsview>
      <about
        if={active.get("about")}
      >
      </about>
      <links
        state={state}
        if={active.get("links")}
      >
      </links>
      <browse
        state={state}
        if={active.get("browse")}
      >
      </browse>
    </div>
    <div
      class="footer"
      if={false}
    >
      <div class="container">
        <div class="columns">
          <div class="col-2">
            <a
              class="mailme"
              href="mailto:wjak56@gmail.com"
            >
              <i class="fa fa-envelope-o" aria-hidden="true"></i>
            </a>
          </div>
          <div class="col-8">
            <div class="license">
              Content Licensed under CC
              <a
                target="_blank"
                rel="noopener"
                href="https://creativecommons.org/licenses/by-nc-nd/4.0/"
              >
                <img
                  class="cc-license"
                  src="/images/88x31.png"
                >
                </img>
              </a>
            </div>
          </div>
          <div class="col-2"></div>
        </div>
      </div>
    </div>
  </div>
<script>
import './sidebar.tag';
import './navtab.tag';
import './projects.tag';
import './postsview.tag';
import './about.tag';
import './links.tag';
import './browse.tag';
import './headersocial.tag';
import './githubsocial.tag';

import route from 'riot-route';
import lens from './lenses.js';
import { throttle } from 'lodash-es';

const hashLength = 8;

var self = this;

self.showBorder = false;
self.route = route;
self.riot = riot;
self.menuActive = false;
self.currentPage = self.opts.title;

self.decode = (x) => JSON.parse(decodeURIComponent(x));

window.addEventListener("scroll",
  throttle((ev) => {
    self.update({"showBorder" : window.pageYOffset != 0});
  },
  400)
);

document.addEventListener("click", function(event) {
  if(!event.target.closest('#menu')) {
    if (self.menuActive) {
      self.menuOff();
    }
  }
});

/* Mostly contains stuff that is preloaded depending on the page accessed initially */
/* Not meant as the ultimate source of truth for everything */
self.state = {
    "pagenum" : 0, /* the current page of posts in the browse tab */
    "browsed" : false, /* was a link clicked to a post yet? */
    "page" : self.opts.page,
    "results" : self.decode(self.opts.results),
    "category_filter" : self.decode(self.opts.category_filter),
    "category_tag" : false, /* used if browse page accessed by a category tag */
    "_id" : self.opts.postid.slice(-hashLength),
    "author" : self.opts.author,
    "title" : self.opts.title,
    "initial" : document.getElementsByTagName("noscript")[0].textContent,
    "links" : self.decode(self.opts.links),
    "categories" : self.decode(self.opts.categories),
    "post_categories" : self.decode(self.opts.post_categories)
};

self.active = lens.actives({
  "projects" : false,
  "posts" : false,
  "links" : false,
  "about" : false,
  "browse" : false
});

menuOn(ev) {
  ev.preventDefault();
  self.menuActive = true;
  self.update();
}

menuOff(ev) {
  if (ev !== undefined) {
    ev.preventDefault();
  }
  self.menuActive = false;
  self.update();
}

self.titles = {
  "browse" : "Wesley Kerfoot",
  "projects" : "GitHub Projects",
  "links" : "Links",
  "about" : "What I Do"
};

function activate(page) {
  return function() {
    if (page != "posts") {
      self.currentPage = self.titles[page];
      document.title = self.currentPage;
    }
    self.active = lens.setActive(self.active, page);
    self.update();
  };
}

var projects = activate("projects");
var about = activate("about");
var links = activate("links");
var browse = activate("browse");

function posts(_id) {
  if (self.state._id != _id) {
    self.state._id = _id;
  }
  activate("posts")();
  self.update();
}

to(name) {
  return (function(e) {
    /* This may or may not be used as an event handler */
    if (e !== undefined) {
      e.preventDefault();
      this.menuOff(e);
    }
    console.log("routing to " + name);
    if (name != "posts") {
      this.route(name);
    }
    return;
  }).bind(this);
}

self.on("mount", () => {
  window.RiotControl.on("openpost",
    (id) => {
      self.state.browsed = true;
      self.route(`/posts/${id}`);
    }
  );

  window.RiotControl.on("browsecategories",
    (category) => {
      self.state.category_tag = category;
      self.route(`/browse/${category}`);
    });

  window.RiotControl.on("postswitch",
    (ev) => {
      self.update(
        {
          "currentPage" : ev.title
        })
      }
  );

  self.one("updated", () => {
    document.addEventListener("click", function(event) {
      if (!event.target.closest('#categorymodal')) {
        window.RiotControl.trigger("closecategories", event);
      }
    });
  });

  self.route.base('/blog/')
  self.route("/", () => { self.route("/browse"); });
  self.route("/posts", () => { self.route(`/posts/${self.state._id}`); });
  self.route("posts/*", posts);
  self.route("posts", (() => {posts(self.state._id)}));
  self.route("projects", projects);
  self.route("about", about);
  self.route("links", links);
  self.route("browse/*/*", browse);
  self.route("browse/*", browse);
  self.route("browse", browse);
  route.start(true);
});

</script>
</app>
