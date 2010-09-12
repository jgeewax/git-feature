### Quickstart

    curl -L http://github.com/jgeewax/git-feature/raw/master/git-feature.sh | sh

### The story...

With all of my projects, I end up following a workflow that looks something like

    * Create and switch to a feature branch
    * Commit, commit, commit
    * Rebase the feature branch against a parent branch
    * Merge it back into the parent branch
    * Get rid of the feature branch

In git-speak, this roughly translates to

    $ git checkout -b my-new-feature
    $ # work
    $ git add file
    $ git commit -m "some work"
    $ git rebase -i master
    $ # resolve conflicts, change commit message
    $ git checkout master
    $ git merge my-new-feature
    $ git branch -d my-new-feature

This is fine, but it was starting to see like a lot more typing for something
that really a shell script could do.

I looked into git-flow and a few other things and decided to do something
different. All of the things I do are just shell commands... there's nothing 
special except the order in which it's done. So I just made a few very handy 
git aliases that most of the typing for me.

Now, my workflow looks like:

    $ git feature my-new-feature
    this will create a feature branch my-new-feature to be merged into master (Y/n): Y
    $ # work
    $ git add file
    $ git commit -m "work"
    $ git finish

All the stupid crap that I type every time is gone! And a few of the weirder
cases are on there, for example:

##### What if I'm on a feature branch and want to start another off of master?

    $ git feature --current
    my-first-feature
    $ git feature my-second-feature master
    this will create a feature branch my-second-feature to be merged into master (Y/n): Y
    $ git feature --current
    my-second-feature
    $ # (This feature is based off of master, not my-first-feature)

##### What if I want to merge my feature into two separate parent branches?

    $ git feature --current
    my-first-feature
    $ git integrate master
    this will integrate my-first-feature into master (Y/n): Y
    $ git integrate some-other-branch
    this will integrate my-first-feature into some-other-branch (Y/n): Y

##### What if I want to base my branch off of something different?

    $ # (currently on master)
    $ git feature my-new-feature my-other-parent
    this will create a feature branch my-new-feature to be merged into my-other-parent (Y/n): Y
    $ git feature --current
    my-new-feature

##### What if I don't remember the order of the arguments?

    $ # (currently on master)
    $ git feature
    feature name: my-new-feature # <-- I typed this in...
    this will create a feature branch my-new-feature to be merged into master (Y/n): Y

