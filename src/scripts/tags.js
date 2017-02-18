riot.tag2('bbutton', '<button class="btn rounded-button"> </button>', '', '', function(opts) {
});

riot.tag2('comment', '<div class="comment centered"> <div class="card"> <div class="card-header"> <h4 class="card-title">{title} by {author}</h4> </div> <div class="card-body comment-body"> {R.join(⁗ ⁗)(R.repeat(text, 20))} </div> </div> </div>', '', '', function(opts) {
});

riot.tag2('comments', '<div if="{loading}" class="loading comments-loader"> </div> <comment if="{!loading}" each="{comments}" data="{this}"></comment> <textarea onfocus="{clearplaceholder}" onblur="{checkplaceholder}" oninput="{echo}" __disabled="{disabled}" class="{⁗form-input comments centered ⁗ + maxed}" name="textarea" rows="10" cols="50" maxlength="{maxlength}"> {placeholder} </textarea> <div if="{warn}" class="toast toast-danger maxwarn centered"> <button onclick="{closewarning}" class="btn btn-clear float-right"> </button> You\'ve reached the max comment size </div>', '', '', function(opts) {

comments = [];
maxlength = 700;

placeholder = "Comment here!";
focused = false;
maxed = false;
warn = false;
disabled = "";
loading = true;

this.clearplaceholder = function() {
  if (!this.focused) {
    this.update({
      "placeholder" : "",
      "focused"     : true
      })
  }
}.bind(this)

this.checkplaceholder = function() {
  if (this.textarea.value.trim().length == 0) {
    this.update({
      "placeholder" : "Comment here!",
      "focused"     : false
    });
  }
}.bind(this)

this.closewarning = function() {
  this.update({"warn" : false});
}.bind(this)

this.echo = function(ev) {
  if (this.textarea.value.length >= maxlength) {
    this.update({
      "maxed" : "maxinput",
      "warn"  : true
    });
  }
  else {
    this.update({
      "maxed" : false,
      "warn"  : false
    });
    window.setTimeout(this.closewarning, 5000);
  }
}.bind(this)

var self = this;

this.getComments = function(pid) {
  fetch("/comments/"+pid)
    .then(
      function(resp) {
        return resp.text();
      })
    .then(
      function(body) {
        self.update(
          {
            "comments" : JSON.parse(body),
            "loading"  : false
          });
      });
}.bind(this)

this.on("mount",
  function() {
    this.getComments(self.opts.pid);
  });

});

riot.tag2('post', '<div class="postnav centered"> <button class="{⁗btn btn-primary ⁗ + (this.pid <= 1 ? ⁗disabled⁗ : ⁗ ⁗) + this.prevloading}" onclick="{prev}">Previous Post</button> <button class="{⁗btn btn-primary ⁗ + (this.nomore ? ⁗disabled⁗ : ⁗ ⁗) + this.nextloading}" onclick="{next}">Next Post</button> </div> <h4 class="post centered" if="{nomore}"> No More Posts! </h4> <div if="{!(loading || nomore)}" class="post centered"> <h4>{opts.title}</h4> <h5>By {opts.creator}</h5> <p class="post-content centered text-break">{content}</p> <div class="divider"></div> <comments pid="{pid}"> </comments> </div>', '', '', function(opts) {
var self = this;

this.loading = false;
this.prevloading = "";
this.nextloading = "";

this.nomore = false
this.pid = 1;
content = "";

this.prev = function() {
  if (self.prevloading || self.nextloading) {
    return;
  }
  self.prevloading = " loading";
  if (self.nomore) {
    self.nomore = false;
  }
  if (self.pid > 1) {
    self.pid--;
    self.setPost(self.pid);
    self.update();
  }
}.bind(this)

this.next = function() {
  if (self.nextloading || self.prevloading) {
    return;
  }
  self.nextloading = " loading";
  console.log(self.pid);
  console.log(self.nomore);
  if (!self.nomore) {
    self.pid++;
    self.setPost(self.pid);
    self.update();
  }
}.bind(this)

this.setPost = function(pid) {
  self.update();
  self.loading = true;
  fetch("/switchpost/"+pid)
    .then(
      function(resp) {
        return resp.text();
      })
    .then(
      function(body) {
        if (body === "false") {
          self.nomore = true;
          route("/");
          self.update()
        }
        else {
          self.content = R.join(" ")(R.repeat(body, 20));
          route("/"+pid);
        }

        self.loading = false;
        self.prevloading = "";
        self.nextloading = "";
        self.update();
      });
}

this.on("mount", function() { this.setPost(self.pid) });

});

riot.tag2('posts', '<yield></yield>', '', '', function(opts) {
});