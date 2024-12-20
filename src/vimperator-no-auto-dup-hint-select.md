2017-03-13T12:27 firefox,vimperator,hint
# Why vimperator hint mode doesn't weed out duplicate links

Vimperator has a commonly used "hint" mode where you may enter either a
generated combination of characters or link's text to interact with that element.

As you type characters in, vimperator filters out matching links for
you. For example, if there's two links with the text "About" in them, typing in
'a', 'b', ... slowly narrows the selection down to these items.

But what if you've typed "Abo" and there's two "About" links (and nothing else
containing "abo" in the page) pointing to the exact same href? Shouldn't
vimperator just go ahead and load either on its own? Yeah, let's try to patch
that in.

-----------------------

`common/content/hints.js` handles this mode.

Looking at it you will likely be drawn to a `_checkUnique` function, but that
only deals with entering "hintchars", not matching against the element's text.

    if (this._hintNumber * options.hintchars.length <= this._validHints.length) {
        let timeout = options.hinttimeout;
        if (timeout > 0)
            this._activeTimeout = this.setTimeout(function () { this._processHints(true); }, timeout);
        return false;
    }

You will also find  `_showHints` which calls the `hintMatcher`. This
matcher is not aware of anything but the string the user has given and the
link text, so there the filtering on the level that we want to happen is
not going to be placed there.

    let validHint = this._hintMatcher(this._hintString.toLowerCase());

    ...

    let valid = validHint(hint.text);

But what calls `_showHints` that could be handling our use-case?
The `_onInput` function. You will notice the behavior is to not decide on a
link until the selection has been narrowed down to one link. A-ha, this is
what we want to change. We want to interate over the still-matching
`elem`s and see if they all link to the same URL, right?

    this._showHints();
    if (this._validHints.length == 1)
        this._processHints(false);

For that we need to extract the URL from `elem`. I see `elem` is a child of
`hint`, but there's no reference to `elem.url` or anything similar anywhere in
the code.

How is a link even followed then? Looking at the `show` function, you will see
that a lookup is made on the `_hintModes` table to figure out how to do that.
You'll then see the entire `elem` is passed to `buffer.followLink`. Weird, why
does it need that entire object?

    this._hintMode = this._hintModes[minor];
    commandline.input(this._hintMode.prompt, null, { onChange: this.closure._onInput });

    ...

    o: Mode("Follow hint",                          function (elem) buffer.followLink(elem, liberator.CURRENT_TAB)),

A-ha. `followLink` does a fake click...

    /**
     * Fakes a click on a link.
     *
     * ...
     */

And now why vimperator doesn't _already_ do the filtering I wanted to patch in
is obvious. Javascript makes it impossible to decide whether two links are the
same, thus you can't guess which one to click if there is _any_ doubt.

Woops. No patching today.
