# Simpler Bijective Burrows-Wheeler Transform
# Based on algorithm described here:
# http://www.glastonbridge.co.uk/amy/amylib/bbwt.html

(de encodeBBWT (L Debug)
   (let
      (BWT NIL
         Word NIL
         FC NIL
         NC NIL
         Put   # Add a symbol to a bucket (order is important! for decoding)
         '((B C)
            (and Debug (msg "======== Put B: " B " C: " C))
            (let
               (V (lup BWT B)
                  V1 (car V)
                  V2 (car (cdr V)) )
               (cond
                  (V
                     (setq B (cons V1 (list (cons C V2))))
                     (idx 'BWT V NIL) )
                  (T (setq B (cons B (cons (list C))))) )
               (idx 'BWT B T) ) )
         
         Bwt   # Put bits of semi-lyndon word in respective buckets
         '((W)
            (and Debug (msg "======== Bwt: " W))
            (let (C (car W))
               (while (car W)
                  (if (not (cdr W))
                     (Put C (car W))
                     (Put (car (cdr W)) (car W)) )
                  (pop 'W) ) ) ) )

      # Make sure we have a list...
      (and Debug (msg "#### L: " L))
      (when (lst? L)
         (and Debug (msg "# Parse input list into semi-Lyndon words and build graph"))
         (when (car L)
            (setq NC (pop 'L)  FC NC  Word (cons NC))
            (while (car L)
               (setq NC (pop 'L))
               (when (< NC FC)
                  (and Debug (msg (text "++++ FC: @1 NC: @2 Word: @3" FC NC (pack (reverse Word)))))
                  (Bwt (reverse Word))
                  (setq FC NC)
                  (setq Word NIL) )
               (setq Word (cons NC Word)))
            (and Debug (msg (text "#### FC: @1 NC: @2 Word: @3" FC NC (pack (reverse Word)))))
            (if Word (Bwt (reverse Word))) ) )
      (and Debug (msg "######## BWT: " (idx 'BWT)))
      (fish atom 
         (make (for X (idx 'BWT) (link (car (cdr X))) ) ) ) ) )

# ---------------------------------------------
# Take an list created by (encodeBBWT)
# and reverse it to get back the original list
 
(de decodeBBWT (L Debug) 
   (use (CNTS CNT V B P)
      (let (Str NIL
         Nxt '(() 
               (let (V (idx 'CNTS) I (pop 'V))
                  (and Debug (msg (text ">>>> Nxt  CNTS: @1 I: @2" (idx 'CNTS) I)))
                  (while (and I (not (car (cdr I))))
                     (setq I (pop 'V)) )
                  (and Debug (msg (text "<<<< Nxt  I: @1 = @2" (car I) (car (cdr I)))))
                  (car I)))
         Get '((B) 
               (let (V (lup CNTS B) 
                     N (car V) 
                     E (car (cdr V)) 
                     C NIL)
               (when (not E)  # Bucket empty
                  (setq B (Nxt) # Get next non-empty bucket
                     V (lup CNTS B)
                     N (car V)
                     E (car (cdr V)) ) )
               (and Debug (msg (text "---- Get B: @1 V: @2 N: @3 E: @4" B V N E)))
               (when V 
                  (idx 'CNTS V NIL)
                  (setq C (pop 'E))
                  (setq V (cons N (list E)))
                  (idx 'CNTS V T) )
               C) ) )
         (and Debug (msg (text "#### L: @1" L)))
         (when (lst? L)
            (and Debug (msg "# Count distinct values (our buckets)"))
            (for X L 
               (setq V (lup CNTS X) CNT (car (cdr V))) 
               (idx 'CNTS V NIL) 
               (idx 'CNTS (list X (+ 1 (or CNT 0))) T))
            (setq B (idx 'CNTS))
            (setq CNTS NIL)
            (and Debug (msg (text "===== Counts: @1" B)))
            (and Debug (msg "# Fill buckets (build graph)"))
            (for X B
               (setq V NIL)
               (do (cadr X) (setq V (cons (pop 'L) V)))
               (setq V (list (car X) (reverse V)))
               (idx 'CNTS V T) )
            (and Debug (msg (text "===== Graph: @1" (idx 'CNTS))))
            (and Debug (msg "# Traverse the graph"))
            (setq P (Nxt)) 
            (and Debug (msg (text "++++++++ P: @1" P)))
            (while (setq P (Get P)) 
               (and Debug (msg (text "____ P: @1" P))) 
               (setq Str (cons P Str) P (car Str)))
         )
         (and Debug (msg "---- done ----"))
         (and Debug (msg (pretty (idx 'CNTS))))
         Str ) ) )

