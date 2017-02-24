# picolisp-bbwt
A Simpler Bijective Burrows-Wheeler Transform

All credit for the algorithm implemented here goes to excellent writeup at //www.glastonbridge.co.uk/amy/amylib/bbwt.html

The following is mostly a quote/summary/paraphrase from that page:

> The Burrows Wheeler Transform is a transform that takes a string and it transforms it into a form that is easier to compress by grouping like characters together. The transform itself doesn't do any compressing. 

> The original Burrows Wheeler Transform requires a little bit of extra information appended to it in order for it to be reversible, hence the development of the Bijective variant, which does not.


# the algorithm

Given a sequence of symbols, factor the symbols into "Pseudo-Lyndon words".

~~~~
"Pseudo-Lyndon words": A sequence of symbols in which no symbol is 'smaller' than its first symbol.
~~~~

When we have split up our input into  such sublists, all we need to do is write our encoder to consider that the symbol that follows the last symbol of a sublist isn't actually the next symbol in the list, but the first symbol in the current sublist. 

There is a slight added complexity to the decoder in this case. The problem is that when we encounter the first symbol in the last word (as we decode from right to left), we want to take a symbol out of its bucket, which by this time is empty. So we simply move onto the next occupied bucket and start a new word. We only need to traverse the input once without storing any intermediate permutation data, and we don't need another list to tell us if we have visited a character once already, because it is easy to see if we have emptied a bucket as the symbols list for the bucket will be empty (NIL)

Finally note that the encoded symbol list is effectively a graph that is 'almost' a Euler Path. To decode, we walk that path. When we enter a node that has no more edges then we 'jump' to the next non-empty node.
