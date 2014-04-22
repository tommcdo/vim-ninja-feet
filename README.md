ninja-feet.vim
==============

In [Practical Vim][1] by [Drew Neil][2], a [cute illustration][3] outlines the
difference between Vim's standard motions and text objects. In short, we see a
ninja kicking in one direction (a motion) compared to a ninja kicking in two
directions (a text object).

![Ninja with feet][4]

While Vim has a great number of wonderful text objects, and plugins can add
even more, there is no general way to operate from the cursor to the beginning
or end of those text objects.

Well, now there is. ninja-feet.vim lets you do so by putting `[` or `]` between
the operator and the text object. For example, `d]i)` deletes from the cursor
to the end of the current parenthetical term. `c[ip` changes from the cursor to
the beginning of the paragraph.

You can also jump into Insert mode at the beginning or end of a text object
(technically, any motion) with `z[` and `z]`.

[1]: http://pragprog.com/book/dnvim/practical-vim
[2]: http://drewneil.com/
[3]: https://twitter.com/odcmmot/status/432254338925617152
[4]: https://cloud.githubusercontent.com/assets/474504/2637472/c059e14a-be9d-11e3-9d9f-98ec51259587.png
