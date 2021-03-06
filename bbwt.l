# Simpler Bijective Burrows-Wheeler Transform
# Based on algorithm described here:
# http://www.glastonbridge.co.uk/amy/amylib/bbwt.html

(de encodeBBWT (L Debug)
   (let
      (BWT NIL
         Word NIL
         FC NIL
         NC NIL
         Put
         '((B C)
            '(and Debug (msg "======== Put B: " B " C: " C))
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
         Bwt
         '((W)
            '(and Debug (msg "======== Bwt: " W))
            (let (C (car W))
               (while (car W)
                  (if (not (cdr W))
                     (Put C (car W))
                     (Put (car (cdr W)) (car W)) )
                  (pop 'W) ) ) ) )
      (and Debug (msg "#### L: " L))
      (when (lst? L)
         (and Debug (msg "# Parse input list into semi-Lyndon words and build graph"))
         (when (car L)
            (setq NC (pop 'L)  FC NC  Word (cons NC))
            (while (car L)
               (setq NC (pop 'L))
               (when (< NC FC)
                  (and
                     Debug
                     (msg (text "++++ FC: @1 NC: @2 Word: @3" FC NC (pack (reverse Word)))) )
                  (Bwt (reverse Word))
                  (setq FC NC Word NIL) )
               (setq Word (cons NC Word)) )
            (and
               Debug
               (msg (text "#### FC: @1 NC: @2 Word: @3" FC NC (pack (reverse Word)))) )
            (if Word (Bwt (reverse Word))) ) )
      (and Debug (msg "######## BWT: "))
      (setq *BBWT (idx 'BWT))
      (fish
         atom
         (make
            (for X (idx 'BWT)
               (link (car (cdr X))) ) ) ) ) )

# ---------------------------------------------
# Take a list created by (encodeBBWT)
# and reverse it to get back the original list

(de decodeBBWT (L Debug)
   (use (CNTS CNT V B P)
      (let
         (Str NIL
            Nxt
            '(NIL
               (let (V (idx 'CNTS)  I (pop 'V))
                  '(and Debug (msg (text ">>>> Nxt  CNTS: @1 I: @2" (idx 'CNTS) I)))
                  (while (and I (not (car (cdr I))))
                     (setq I (pop 'V)) )
                  '(and
                     Debug
                     (msg (text "<<<< Nxt  I: @1 = @2" (car I) (car (cdr I)))) )
                  (car I) ) )
            Get
            '((B)
               (let
                  (V (lup CNTS B)
                     N (car V)
                     E (car (cdr V))
                     C NIL )
                  (when (not E)
                     (setq
                        B (Nxt)
                        V (lup CNTS B)
                        N (car V)
                        E (car (cdr V)) ) )
                  '(and Debug (msg (text "---- Get B: @1 V: @2 N: @3 E: @4" B V N E)))
                  (when V
                     (idx 'CNTS V NIL)
                     (setq C (pop 'E)
                           V (cons N (list E)))
                     (idx 'CNTS V T) )
                  C ) ) )
         (and Debug (msg (text "#### L: @1" L)))
         (when (lst? L)
            (and Debug (msg "# Count distinct values (our buckets)"))
            (for X L
               (setq V (lup CNTS X)  CNT (car (cdr V)))
               (idx 'CNTS V NIL)
               (idx
                  'CNTS
                  (list X (+ 1 (or CNT 0)))
                  T ) )
            (setq B (idx 'CNTS)
                  CNTS NIL)
            (and Debug (msg (text "===== Counts: @1" B)))
            (and Debug (msg "# Fill buckets (build graph)"))
            (for X B
               (setq V NIL)
               (do (cadr X)
                  (setq V (cons (pop 'L) V)) )
               (setq V (list (car X) (reverse V)))
               (idx 'CNTS V T) )
            (and Debug (msg (text "===== Graph: @1" (idx 'CNTS))))
            (and Debug (msg "# Traverse the graph"))
            (setq P (Nxt))
            '(and Debug (msg (text "++++++++ P: @1" P)))
            (while (setq P (Get P))
               '(and Debug (msg (text "____ P: @1" P)))
               (setq Str (cons P Str)  P (car Str)) ) )
         (and Debug (msg "---- done ----"))
         (and Debug (msg (pretty (idx 'CNTS))))
         Str ) ) )
 
NIL

: (encodeBBWT (chop Str) T)
"#### L: "SIX.MIXED.PIXIES.SIFT.SIXTY.PIXIE.DUST.BOXES
"# Parse input list into semi-Lyndon words and build graph"
"++++ FC: S NC: I Word: S"
"++++ FC: I NC: . Word: IX"
"#### FC: . NC: S Word: .MIXED.PIXIES.SIFT.SIXTY.PIXIE.DUST.BOXES"
"######## BWT: "
(("." ("S" "T" "E" "Y" "T" "S" "D"))
   ("B" ("."))
   ("D" ("." "E"))
   ("E" ("X" "I" "I" "X"))
   ("F" ("I"))
   ("I" ("X" "P" "S" "S" "X" "P" "M" "X"))
   ("M" ("."))
   ("O" ("B"))
   ("P" ("." "."))
   ("S" ("E" "U" "." "." "E" "S"))
   ("T" ("S" "X" "F"))
   ("U" ("D"))
   ("X" ("O" "I" "I" "I" "I" "I"))
   ("Y" ("T")) )" )"
-> ("S" "T" "E" "Y" "T" "S" "D" "." "." "E" "X" "I" "I" "X" "I" "X" "P" "S" "S" "X" "P" "M" "X" "." "B" "." "." "E" "U" "." "." "E" "S" "S" "X" "F" "D" "O" "I" "I" "I" "I" "I" "T")

: (decodeBBWT (encodeBBWT (chop Str)) T)
"#### L: STEYTSD..EXIIXIXPSSXPMX.B..EU..ESSXFDOIIIIIT"
"# Count distinct values (our buckets)"
"===== Counts: .7B1D2E4F1I8M1O1P2S6T3U1X6Y1"
"# Fill buckets (build graph)"
"===== Graph: .STEYTSDB.D.EEXIIXFIIXPSSXPMXM.OBP..SEU..ESTSXFUDXOIIIIIYT"
"# Traverse the graph"
"---- done ----"
(("." NIL)
   ("B" NIL)
   ("D" NIL)
   ("E" NIL)
   ("F" NIL)
   ("I" NIL)
   ("M" NIL)
   ("O" NIL)
   ("P" NIL)
   ("S" NIL)
   ("T" NIL)
   ("U" NIL)
   ("X" NIL)
   ("Y" NIL) )" )"
-> ("S" "I" "X" "." "M" "I" "X" "E" "D" "." "P" "I" "X" "I" "E" "S" "." "S" "I" "F" "T" "." "S" "I" "X" "T" "Y" "." "P" "I" "X" "I" "E" "." "D" "U" "S" "T" "." "B" "O" "X" "E" "S")


