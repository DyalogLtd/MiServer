﻿:class Icon : #._html.i
⍝ Description:: Dyalog Icon widget
⍝ Constructor:: [spec [order]]
⍝ spec - either a single or pair of string which specify the icon(s) to use
⍝        each consists of a vendor-prefix, dash, icon-name, and optionally space-separated modifiers
⍝        when two strings are used, it represents a "stacked" icon, with second icon overlayed on the first
⍝        "stacked" icons are a feature of FontAwesome icons - using other icons may or may not have the desired visual effect
⍝ order - when stacking: 0 indicates that the second icon is small and overlayed on a large first icon
⍝                        1 indicates that the second icon is large and overlayed on a small first icon
⍝ Public Fields::
⍝ Spec  - either a single or pair of string which specify the icon(s) to use
⍝         each consists of a vendor-prefix, dash, icon-name, and optionally space-separated modifiers
⍝         when two strings are used, it represents a "stacked" icon, with second icon overlayed on the first
⍝         "stacked" icons are a feature of FontAwesome icons - using other icons may or may not have the desired visual effect
⍝ Order - when stacking: 0 indicates that the second icon is small and overlayed on a large first icon
⍝                        1 indicates that the second icon is large and overlayed on a small first icon
⍝ Examples::
⍝ Add _.Icon 'fa-cloud-upload'    ⍝ FontAwesome: http://fontawesome.io/icons/
⍝ Add _.Icon 'md-fingerprint'     ⍝ Google Material Design: https://design.google.com/icons/
⍝ Add _.Icon 'e-delete-column_01' ⍝ Syncfusion Essential JavaScript: http://js.syncfusion.com/demos/web/#!/azure/icon/EJIcons
⍝ '.fa-spin' Add _.Icon 'md-track_changes' ⍝ FontAwesome effects (works on non-FA icons too)
⍝ 'style="color: red;"' Add _.Icon 'e-stop' ⍝ Applying own styling
⍝ Add _.Icon 'fa-square' 'fa-terminal fa-inverse' ⍝ Stacking inverse small on large
⍝ Add _.Icon 'fa-camera' 'fa-ban' 1 ⍝ Stacking large on small

    :field public shared readonly ApiLevel←3
    :Field public Spec←⍬
    :Field public Order←0
    :field public shared readonly DocBase←'http://fontawesome.io/examples/'

    ∇ Make
      :Access public
      :Implements constructor
    ∇

    ∇ Make1 args;numeric;last
      :Access public
      :Implements constructor
      :If 2|⎕DR last←⊃¯1↑Spec←args
          Order←last ⋄ Spec←¯1↓args
      :EndIf
    ∇

    ∇ r←Render;prefix;spec;icon;classes
      :Access public
      Spec←eis Spec
      :If 1=⍴Spec ⍝ Simple icon
          (prefix spec)←(⊃Spec)SplitOn1st'-'
          :Select prefix
          :Case 'fa' ⍝ FontAwesome
              Use'faIcons'
              AddClass'fa ',⊃Spec
     
          :Case 'md' ⍝ Google
              Use'mdIcons'
              (icon classes)←(spec,' ')SplitOn1st' '
              AddClass'material-icons ',classes
              Content←icon
     
          :CaseList (,'e')'ej' ⍝ Syncfusion
              Use'ejIcons'
              AddClass'e-icon e-',spec
              AddStyle'display: inline-block'  ⍝ add this because default Syncfusion is "block"
     
          :EndSelect
      :Else
          Use'faIcons'
          AddClass'fa-stack'
          Spec(Add _.Icon{⍺ ⍵},)¨⌽⍣(~Order)(' fa-stack-','x',⍨⍕)¨⍳⍴Spec
     
      :EndIf
      SetUse
      r←⎕BASE.Render
    ∇

    SplitOn1st←{⎕ML←3 ⋄ (~<\⍺∊⍵)⊂⍺}
:endclass