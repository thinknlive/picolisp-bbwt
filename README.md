# picolisp-bbwt
A Simpler Bijective Burrows-Wheeler Transform

All credit for the algorithm implemented here goes to the excellent writeup at //www.glastonbridge.co.uk/amy/amylib/bbwt.html

Most of the following info is just a quote/summary/paraphrase from that page:

> The Burrows Wheeler Transform is a transform that takes a string and it transforms it into a form that is easier to compress by grouping like characters together. The transform itself doesn't do any compressing, but then you can use run-length encoding on it, for instance

> The original Burrows Wheeler Transform requires a little bit of extra information appended to it in order for it to be reversible, hence the development of the Bijective variant, which does not.


# the algorithm

Given a sequence of symbols, factor the symbols into "Pseudo-Lyndon words".

> "Pseudo-Lyndon words": A sequence of symbols in which no symbol is 'smaller' than its first symbol.

When we have split up our input into such sublists, all we need to do is write our encoder to consider that the symbol that follows the last symbol of a sublist isn't actually the next symbol in the list, but the first symbol in the current sublist. 

There is a slight added complexity to the decoder in this case. The problem is that when we encounter the first symbol in the last word (as we decode from right to left), we want to take a symbol out of its bucket, which by this time is empty. So we simply move onto the next occupied bucket and start a new word. We only need to traverse the input once without storing any intermediate permutation data, and we don't need another list to tell us if we have visited a character once already, because it is easy to see if we have emptied a bucket as the symbols list for the bucket will be empty (NIL)

Finally, note that the encoded symbol list is effectively a graph that is 'almost' a Euler Path. To decode, we walk that path. When we enter a node that has no more edges then we 'jump' to the next non-empty node. Remember that each node represents a distinct symbol from the input. Nodes are ordered.

~~~~

: Str
-> "SIX.MIXED.PIXIES.SIFT.SIXTY.PIXIE.DUST.BOXES"
: (pack (encodeBBWT (chop Str)))             
-> "STEYTSD..EXIIXIXPSSXPMX.B..EU..ESSXFDOIIIIIT"
: (pack (decodeBBWT (encodeBBWT (chop Str))))
-> "SIX.MIXED.PIXIES.SIFT.SIXTY.PIXIE.DUST.BOXES"
: (= Str (pack (decodeBBWT (encodeBBWT (chop Str)))))
-> T

: (setq PI 1415926535897932384626433832795028841971693993751058209749445923)
-> 1415926535897932384626433832795028841971693993751058209749445923
: (setq PI_L (mapcar format (chop (format 1415926535897932384626433832795028841971693993751058209749445923))))
-> (1 4 1 5 9 2 6 5 3 5 8 9 7 9 3 2 3 8 4 6 2 6 4 3 3 8 3 2 7 9 5 0 2 8 8 4 1 9 7 1 6 9 3 9 9 3 7 5 1 0 5 8 2 0 9 7 4 9 4 4 5 9 2 3)
: (encodeBBWT PI_L)
-> (3 2 1 5 7 4 5 4 9 8 0 3 6 3 9 2 9 9 8 3 4 2 9 5 4 9 7 8 6 8 1 4 0 7 9 3 6 1 1 2 4 2 9 3 9 2 9 5 8 2 3 3 5 5 4 0 9 3 6 1 7 7 8 5)
: (decodeBBWT (encodeBBWT PI_L))
-> (1 4 1 5 9 2 6 5 3 5 8 9 7 9 3 2 3 8 4 6 2 6 4 3 3 8 3 2 7 9 5 0 2 8 8 4 1 9 7 1 6 9 3 9 9 3 7 5 1 0 5 8 2 0 9 7 4 9 4 4 5 9 2 3)
: (= PI_L (decodeBBWT (encodeBBWT PI_L)))
-> T

~~~~
