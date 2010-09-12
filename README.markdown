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
cases are on there. 

### WARNING

This is my *personal* git workflow. It works for me. It might not work for you.
I really like rebasing all the commits for a feature into one commit, though
that's just my personal preference. 

This has *NOT yet* been thoroughly tested! I've done *some* testing for 
weird situations where rebasing throws errors and everything freaks out. If you
find yourself stuck, *DON'T PANIC*. git-feature isn't doing anything magical.
All it is is a bunch of git commands strung together in a particular order.

If something goes wrong while integrating or finishing, a quick "reset and start
over" would be...

    $ git checkout features/your-feature-name
    $ git rebase --abort

and your feature branch should be back exactly where it was.

### Now onto the questions...

#### How do I work on features?

    $ # (currently on master)
    $ git feature my-new-feature
    this will create a feature branch my-new-feature to be merged into master (Y/n): Y

#### OK, I'm done working. How do I integrate my work back into master?

    $ git feature --current
    my-new-feature
    $ git integrate master
    this will integrate my-new-feature into master (Y/n): Y

#### What if I want to throw away the feature branch?

    $ git feature --current
    my-new-feature
    $ git finish
    this will integrate my-new-feature into master (Y/n): Y

#### What if I'm not on master but want to start a feature branch off of master?

    $ # (not currently on master...)
    $ git feature my-new-feature master
    this will create a feature branch my-new-feature to be merged into master (Y/n): Y
    $ git feature --current
    my-new-feature
    $ # (This feature is based off of master, not my-first-feature)

#### What if I want to integrate my feature into two different parent branches?

    $ git feature --current
    my-first-feature
    $ git integrate master
    this will integrate my-first-feature into master (Y/n): Y
    $ git integrate some-other-branch
    this will integrate my-first-feature into some-other-branch (Y/n): Y

#### What if I want to base my branch off of something different?

    $ # (currently on master)
    $ git feature my-new-feature my-other-parent
    this will create a feature branch my-new-feature to be merged into my-other-parent (Y/n): Y
    $ git feature --current
    my-new-feature

#### What if I don't remember the order of the arguments?

    $ # (currently on master)
    $ git feature
    feature name: my-new-feature # <-- I typed this in...
    this will create a feature branch my-new-feature to be merged into master (Y/n): Y
    $ git feature --current
    my-new-feature
    $ git feature
    feature name: my-second-feature # <-- I typed this in...
    where will this feature be merged into when it is done? master # <-- I typed this in too...
    this will create a feature branch my-second-feature to be merged into master (Y/n): Y

#### What if I'm working on something and need to work on something else?

Since I rebase all my commits (and `git finish` will try to get you to rebase as
well), I usually run `git add -A && git commit -m "Checkpoint"` to stash my
commits on my current feature branch. 

I found myself doing that so often that I just made it an alias...

    $ git feature my-first-feature
    this will create a feature branch my-first-feature to be merged into master (Y/n): Y
    $ # (do work)
    $ git checkpoint
    $ git feature my-second-feature
    where will this feature be merged into when it is done? master
    this will create a feature branch my-second-feature to be merged into master (Y/n): Y

This makes it relatively easy to save where you were and move onto another task.

#### What if I have work that I need on my feature branch, but it isn't specific to my feature?

This might be another personal preference, but I like to keep a feature branch 
focused on the feature. That is, if I need to update a library that other people
might need or use, I like to put that in another feature and the pull those
changes over from the parent. This would look like...

    $ git feature my-first-feature
    this will create a feature branch my-first-feature to be merged into master (Y/n): Y
    $ # (do work)
    $ # (think of something that needs to be shared...)
    $ git checkpoint
    $ git feature edit-library
    where will this feature be merged into when it is done? master
    this will create a feature branch library to be merged into master (Y/n): Y
    $ # (do work)
    $ git finish
    this will integrate edit-library into master (Y/n): Y
    $ git feature my-first-feature
    $ git rebase master
    $ # (do more work)
    $ git finish
    this will integrate my-first-feature into master (Y/n): Y

The rebase basically brings your branch up to speed relative to master and you
(and other people on your team) can continue working on your feature with the
changes to library being separate from your feature work. 

### Questions about how all this works...

#### How does this work...?

In short, I just put some fancy aliases together that uses shell scripting to
do fancier stuff.

#### When I do git finish, how do you know where to integrate into?

When you create a feature (`git feature`), the shell script runs

    git config (feature).parent (parent)

so that we know the default parent. Don't worry, when you finish a feature it 
gets removed from the config. Also, it's just the local config, so another git
repository won't know about it.

If you want to get rid of one manually:

    $ git branch -D features/your-feature-name
    $ git config --remove-section your-feature-name
