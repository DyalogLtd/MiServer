﻿:Namespace MS3SiteUtils ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝
⍝ ┌─────────────────────────────────────────────────────────────────────────────────────────────┐ ⍝
⍝ │ This is the collection of utility functions used by MS3Server and the index page of the     │ ⍝
⍝ │ MiServer Sample Site, MS3, accessible at miserver.dyalog.com                                │ ⍝
⍝ ├─────────────────────────────────────────────────────────────────────────────────────────────┤ ⍝
⍝ │ The code is split up in six sections:                                                       │ ⍝
⍝ │                                                                                             │ ⍝
⍝ │     ∘ A_GENERAL has utilities that appropriate to APL or MiServer in general                │ ⍝
⍝ │                                                                                             │ ⍝
⍝ │     ∘ B_FILES has various tools to list, read, and cache files and their content            │ ⍝
⍝ │                                                                                             │ ⍝
⍝ │     ∘ C_STRINGS string and multi-string manipulation and extraction of information          │ ⍝
⍝ │                                                                                             │ ⍝
⍝ │     ∘ D_ELEMENTS aids to create elements for the HTML Document Object Model                 │ ⍝
⍝ │                                                                                             │ ⍝
⍝ │     ∘ E_TUTORIAL has subroutines for the Tutorial tab on the index page                     │ ⍝
⍝ │                                                                                             │ ⍝
⍝ │     ∘ F_CONSTANTS niladic functions that return unchanging values and cache                 │ ⍝
⍝ │                                                                                             │ ⍝
⍝ └─────────────────────────────────────────────────────────────────────────────────────────────┘ ⍝
⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝

    :SECTION A_GENERAL ⍝ UTILITY FUNCTIONS THAT ARE NOT SPECIFIC TO THE "MS3" SITE

    Ⓒ←{⊂⍣(1=≡,⍵)⊢⍵} ⍝ enclose if simple     Mnemonic for the ⊆ glyph

    FwSl←'[\\/]+'⎕R'/' ⍝ Make all slash-block into single forward-slashes

    Q←'"'∘,,∘'"' ⍝ Surround with quotes

    FromCSV←↑{'"'~¨⍨1↓¨t⊂⍨(','=t)∧~≠\'"'=t←',',⍵}¨ ⍝ Convert CSV VTV to matrix (no escaped chars)

      Section←{ ⍝ Extract section ⍺:: from code ⍵
          regex←'^\s*⍝\s*',⍺,':(:.*?)$((\R^⍝(?!\s*\w+::).*?$)*)' ⍝ find '  ⍝  LeftArg:: some text'
          opts←('Mode' 'M')('DotAll' 1)('ML' 1)                  ⍝ '^'≡linestart  EOL∊'.'  1st-only
          res←regex ⎕S'\1\2'⍠opts⊢⍵                              ⍝ return parts 1 and 2
          #.Strings.deb'⍝'~⍨1↓⊃res                               ⍝ strip spaces and lamp
      }

      Controls←{ ⍝ Extract names of controls used in sample ⍵
          (Words'Control'Section Read ⍵)~'_',¨NSS
      }

    Of←{⍵/⍨⍺⍺¨⍵} ⍝ Those elements of ⍵ that satisfy ⍺⍺ element

    :ENDSECTION ⍝ ─────────────────────────────────────────────────────────────────────────────────
⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝

    :SECTION B_FILES ⍝ FUNCTIONS THAT READ FILES

    Score←{(102-2×(50↑⊃⌽⍵)⍳⊂⍺)-∨/'Advanced'⍷⊃⍵} ⍝ Relevance score on index of control in list

      List←{ ⍝ Files in site folder
          ⍺←1↓FILEEXT                                      ⍝ default .ext
          mods←' -rec -raw -full=2 -ext=',⍺                ⍝ subdirs no-format rooted spec-ext
          list←(⎕SE.SALT.List #.Boot.AppRoot,⍵,mods)[;1 2] ⍝ begin at application root (MS3/)
          f←~d←list[;1]≡¨⊂'<DIR>'                          ⍝ find dirs
          list←FwSl list[;2]                               ⍝ normalize slashes for WWW
          (d/list),←'/'                                    ⍝ mark dirs with final slashes
          (f/list),←⊂'.',⍺                                 ⍝ add .ext to files
          list↓¨⍨¯1+1⍳⍨(FwSl ⍵)⍷⊃list                      ⍝ trim
      }

    ∇ r←Read page;i ⍝ Read a page via the #.CACHE.read (C)
      :Trap 0
          :If (≢C.read.keys)≥i←C.read.keys⍳⊂page ⍝ is it cached, and if so, save position
              r←i⊃C.read.data                     ⍝ extract
          :Else
              C.read.data,←⊂r←#.Files.GetVTV #.Boot.AppRoot,page,(~'.'∊page)/FILEEXT
              C.read.keys,←⊂page
          :EndIf
      :Else
          r←,⊂'[failed to read "',page,'"]'
      :EndTrap
    ∇

    :ENDSECTION ⍝ ─────────────────────────────────────────────────────────────────────────────────
⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝

    :SECTION C_STRINGS ⍝ MANIPULATION OF CHARACTER VECTORS AND VECTORS OF CHARACTER VECTORS

    Slash←'/'∘=⊂⊢

    Name←{1↓⊃⌽(Slash ⍵)~⊂,'/'}  ⍝ '/aaa/bbb/ccc/ddd/' →         'ddd' (only in BuildTree)

    Words←{(1↓¨(∊∘' .'⊂⊢)' ',⍵)~⊂''} ⍝ Split at spaces and dots and remove empty pieces

    NoExt←{'.'∊⍵:⍵↓⍨-'.'⍳⍨⌽⍵⋄⍵} ⍝ 'aaa.bbb.ccc'  →  'aaa.bbb'

    NoNL←'\n' '\r'⎕R' ' ''⍠'Mode' 'D' ⍝ Replace newlines with spaces

    LastSeg←{⍺←⊢ ⋄ 1↓⍺⊃⌽Slash '/',⍵} ⍝ ⍺th (default 1st) /-separated segment from the end

    Levels←{(+/¨'/'=⍵)+~'/'=(⊃⌽)¨⍵} ⍝ Number of /s adjusted for categories' final /

    Shuffle←(?⍨∘≢⊃¨⊂)⊢⊂⍨⊢≡¨1↑⊢ ⍝ Shuffle the root elements of an XML snippet

    :ENDSECTION ⍝ ─────────────────────────────────────────────────────────────────────────────────
⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝

    :SECTION D_ELEMENTS ⍝ FUNCTIONS THAT AUTOMATE THE CREATION OF DOM ELEMENTS AND HTML CODE

      Over←{
          ⊂'<strong>',⍺,'</strong><br><small>',('/'⎕R'<br />'⊢⍵),'</small>'
      }

      External←{ ⍝ Icon off-site link
          ⍺←''
      ⍝    '.external' 'target=_blank' 'data-dyalog-tip="External link"'New _.A((⍺,'&#x1f517;')⍵)
          '<a class=".external" target="_blank" data-dyalog-tip="External link" href="',⍵,'">',⍺,'&#x1f517;</a>'
      }

      DescrEmbed←{ ⍝ Link to and iframed page
          l←('Description'Section Read ⍵),'<br />'
          l,←'<a target="_blank" href="/',⍵,'">Open this '
          l,←'simple sample' 'advanced sample' 'mini-app'⊃⍨1⍳⍨∨/¨'Simple' 'Advanced'⍷¨⊂⍵
          l,←' in a new tab</a>'
          e←'<iframe src="/',⍵,'?nowrapper=1"></iframe>'
          l e
      }

      Link←{ ⍝ New-tab link with optional (⍺) "tooltip"
          ⍺←0
          ⍝(('data-dyalog-tip=',Q ⍺){⍺ ⍵}⍣(⍺≢0)⊢'target="_blank"')New _.A ⍵
          '<a target="_blank" href=',(Q⊃⌽⍵),((⍺≢0)/' data-dyalog-tip=',Q ⍺),'>',(⊃⍵),'</a>'
      }

      DocLink←{ ⍝ Link to WidgetDoc with appropriate parameters
          link←DocUrl ⍵
          ctor←'ctor'ForControl ⍵
          0=⍴ctor::Link ⍵ link ⍝ upon fail to retrieve info
          ('Constructor: ',ctor)Link ⍵ link
      }

      DocUrl←{
          '/Documentation/DyalogAPIs/WidgetDoc?namespace=_',('ns'ForControl ⍵),'&widget=',⍵
      }

      DocTreeLink←{ ⍝ Link to file in doc folder
          '/'=⊃⌽⍵:''
          ('/Documentation/',⍵)'target="_blank"'
      }

      ReadingTree←{ ⍝ Create tree of documentation links
          l←'/',¨⍵~⊂''
          (Name∘NoExt¨l)(Levels l)(DocTreeLink¨l)
      }

    ∇ r←RelDocs w;list;item ⍝ Links to related samples
      list←'relevant'ForControl w
      r←''
      :For item :In list
          r,←'<p>',(Link('filedescr'ForFile item)item),'</p><br/>'
      :EndFor
      r↓⍨←¯5
    ∇

      FormatList←{ ⍝ List of category-title pairs
          ⍺←1↓FILEEXT
          (⍺≡1↓FILEEXT)CatAndItem¨{'/'≠⊃⌽⍵}Of ⍺ List ⍵
      }

      CatAndItem←{ ⍝ (category) (filename/description)
          cat←2 LastSeg ⍵
          cat←'General' 'Mini App'cat['Documentation' 'Applications'⍳⊂cat]
          cat(Link((NoExt LastSeg)⍣(~⍺)('Description'Section Read)⍣⍺⊢⍵)⍵)
      }

    :ENDSECTION ⍝ ─────────────────────────────────────────────────────────────────────────────────
⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝

    :SECTION E_TUTORIAL ⍝ FUNCTIONS USED BY THE index PAGE'S Tutorial TAB

    ∇ tut←Tutorial;tabs;l;r;sp;fs;ig;colors;rgbs;button;p;cbs
      tut←'#tut'New _.div
      tut.Add _.p'In the tabs below, you will find categorized examples of webpage content. Click any element for more information.'
      tabs←'#Tabs'tut.Add _.Tabs ⍝ #Tabs
      l←'#div'New _.div ⍝ #div
      'Common elements'tabs.AddSection l ⍝ #Tabs
      p←'#p'l.Add _.p'This is a paragraph.' ⍝ #p
      button←'#Button'l.Add _.Button'Button' ⍝ #Button
      sp←'#StackPanel'l.Add _.StackPanel ⍝ #StackPanel
      '#EditField'sp.Add _.EditField'EditField' 'EditField' ⍝ #EditField
      '#Select'sp.Add _.Select'Red' 'Green' 'Blue' ⍝ #Select
      '#Input1'l.Add _.Input'number' 426 ' Number Input: ' ⍝ #Input1
      l.Add _.br
      fs←'#Fieldset1'l.Add _.Fieldset'CheckBoxes' ⍝ #Fieldset1
      cbs←{'.CheckBox'New _.CheckBox ⍵}¨'checked' 'unchecked' ⍝ .CheckBox
      ig←'#InputGrid'fs.Add _.InputGrid('Checked' 'Unchecked')cbs ⍝ #InputGrid
      ig.Flip←1 ⍝ #InputGrid
      fs←'#Fieldset2'l.Add _.Fieldset'RadioButtonGroup' ⍝ #Fieldset2
      '#RadioButtonGroup'fs.Add _.RadioButtonGroup('Selected' 'Unselected')1 'right' ⍝ #RadioButtonGroup
      '#h5'l.Add _.h5'Slider' ⍝ #h52
      '#Input2'l.Add _.Input'range' 1 ⍝ #Input2
      '#List'l.Add _.List('Primaries' 'Cyan' 'Magenta' 'Yellow' 'Key' 'Black')(1 2 2 2 1 2) ⍝ #List
      colors←'aqua' 'black' 'blue' 'fuchsia' 'gray' 'green' 'lime' 'maroon' ⍝ #Table
      rgbs←'#00FFFF' '#000000' '#0000FF' '#FF00FF' '#808080' '#008000' '#00FF00' '#800000' ⍝ #Table
      colors,←'navy' 'olive' 'purple' 'red' 'silver' 'teal' 'white' 'yellow' ⍝ #Table
      rgbs,←'#000080' '#808000' '#800080' '#FF0000' '#C0C0C0' '#008080' '#FFFFFF' '#FFFF00' ⍝ #Table
      '#Table'l.Add _.Table('Color' 'RGB'⍪colors,⍪rgbs)'' 1 ⍝ #Table
      '#info'tut.Add _.div
      tut.Add _.style ScriptFollows
      ⍝ #tut {padding: 10px;}
      ⍝ #info {display: inline-block; width: calc(50% - 15px); vertical-align: top; padding: 5px;}
      ⍝ #info p {text-indent:-4em; padding-left: 4em; font-family: APL385 Unicode;}
      ⍝ #Tabs {width: calc(50% - 15px); display: inline-block; margin-right: 10px;}
      ⍝ #div {padding: 10px;}
      ⍝ #Button {vertical-align: top; margin: 5px;}
      ⍝ #StackPanel {display: inline-block;}
      ⍝ #Fieldset1 {display: inline-block;}
      ⍝ #Fieldset2 {display: inline-block;}
      ⍝ #h5 {margin: 1em 0 0.5em 0;}
      ⍝ #Input1 {width: 4em;}
      ⍝ #Input2 {width: 100%;}
      ⍝ #List {display: inline-block; margin: 1em; padding: 5px;}
      ⍝ #Table {display: inline-block; max-height: 7em; overflow-y: scroll; margin-top: 1em;}
      ⍝
      ⍝ /**/#p:hover, #Tabs:hover, #div:hover, #Button:hover, #StackPanel:hover, #EditField:hover, #Select:hover, #Fieldset1:hover, #Fieldset2:hover, .CheckBox:hover, #RadioButtonGroup:hover, #Input1:hover, #Input2:hover, #h51:hover, #h52:hover, #progress:hover, #List:hover, #Table:hover {
      ⍝     box-shadow: 0 0 5px 1px orange,0 0 5px orange inset;
      ⍝ }
      Interactive¨'#p' '#Tabs' '#div' '#Button' '#EditField' '#StackPanel' '#Select' '#Fieldset1' '#Fieldset2' '.CheckBox' '#RadioButtonGroup' '#Input1' '#h5' '#Input2' '#progress' '#List' '#Table'
     
      {⍵ tabs.AddSection New _.div}¨'Formatting' 'Positioning' 'Embedding' 'Interaction' 'Windows &amp; Popups'
     
    ∇
    ∇ {ctrl}←Interactive sel
      ctrl←sel~'#.12'
      Add _.Handler sel'click' 'ShowCode' '' '' 'event.stopPropagation()'
    ∇

    ∇ r←ShowCode;nr;code;tag;css;lines;ctrl
      :Access Public
      ctrl←_selector~'#.12'
      r←'#info'Replace'<h2>_.',ctrl,'</h2>'
      r,←'#info'Append'<p>',('descr'ForControl ctrl)'</p>'
      r,←'#info'Append'<h3>Constructor</h3><p>',(Link('ctor'ForControl ctrl)(DocUrl ctrl)),'</p>'
      nr←⎕NR'Tutorial'
      tag←'⍝ ',_selector
      code←nr/⍨tag∘(∨/⍷)¨nr
      (css lines)←↓⍉↑Prep¨code
      r,←'#info'Append'<h3>Compose</h3>',Ps lines/⍨~css
      ⍝:If ∨/css
      ⍝    r,←'#info'Append'<h3>CSS</h3>',Ps css/lines
      ⍝:EndIf
    ∇

      Prep←{
          c←#.Strings.dlb ⍵
          tag≡c↑⍨-l←≢tag:0('\w+\.Add'⎕R'Add'⊢c↓⍨¯1-l)
          1(2↓c)
      }
    Ps←∊{'<p>',⍵,'</p>'}¨

    :ENDSECTION ⍝ ─────────────────────────────────────────────────────────────────────────────────
⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝

    :SECTION F_CONSTANTS ⍝ NILADIC FUNCTIONS THAT ACT LIKE :include'ABLE CONSTANTS

    ∇ r←NSS
      :Access public
      r←'DC' 'SF' 'JQ' 'JS' 'html'
    ∇

    ∇ r←GROUPS
      :Access public
      r←'Dyalog' 'Syncfusion' 'jQueryUI' 'JavaScript' 'Base&nbsp;HTML'
    ∇

    ∇ r←CACHE
      :Access public
      r←'#.CACHE'
    ∇

    ∇ r←FILEEXT
      :Access public
      r←#.Boot.ms.Config.DefaultExtension
    ∇

    ∇ C←C;scores;list;refs;srcs;control;i;info;ref;src;ctor;Read;Ø;demo
     ⍝ Return ref to cache (initialize cache if nonexistant)
      :Access public
      Read←#.Files.GetVTV #.Boot.AppRoot∘, ⍝ no-cache reading
      :Hold CACHE                          ⍝ prevent clashes
          :If 9≠⎕NC CACHE                  ⍝ if cache is empty:
              Ø←⊂''
              C←⍎CACHE ⎕NS ⍬       ⍝ create with shortcut
              C.read←⎕NS ⍬         ⍝ init cache for files
              C.read.(keys←data←⍬) ⍝ init keys and data
     
              C.controls←(#._.⎕NL ¯9)~⊂'Handler'                       ⍝ cache all controls
              C.controlsoi←C.controls∘⍳Ⓒ ⋄ C.eocontrols←∊∘C.controls Ⓒ ⍝ hash tables
              refs←#._⍎¨C.controls                                     ⍝ refs of all controls
              C.ns←3↓¨⍕¨refs.##                                        ⍝ ns of each control
              srcs←⎕SRC¨refs                                           ⍝ all sources
     
              C.files←⊃⍪/{List'Examples/',⍵}¨NSS,⊂'Applications' ⍝ sample filenames
              C.filesoi←C.files∘⍳Ⓒ                               ⍝ hash table
              C.filedescr←('Description'Section Read)¨C.files    ⍝ Description:: for all files
              C.demos←Controls¨C.files                           ⍝ controls demoed in each
              scores←C.controls∘.Score↓⍉↑C.files C.demos         ⍝ controls vs files
              C.rankings←(+/0<scores)↑¨↓⍒#.Utils.∆rank 1⊢scores  ⍝ cache all rankings
     
              C.descr←''
              C.ctor←''
              C.notes←''
              C.relevant←''
              C.reldocs←''
              C.doclinks←''
              info←FromCSV Read'IndexData/info.csv'
              :For control ref src :InEach C.controls refs srcs
                  i←info[;1]⍳⊂control
                  :If i≤≢info
                      C.descr,←info[i;2]
                      C.notes,←info[i;3]
                  :Else
                      C.descr,←⊂NoNL'Description'Section src
                      C.notes,←⊂NoNL'Notes'Section src
                  :EndIf
     
                  ctor←{⍵↑⍨¯1+⌊/⍵⍳⎕UCS 13 10}'Constructor'Section src
                  :If ''≡ctor
                      C.ctor,←'[content [attributes]]' '[attributes]'[1+(⎕NEW ref).NoEndTag]
                  :Else
                      C.ctor,←⊂ctor
                  :EndIf
     
                  :If C.eocontrols⊂control
                      C.relevant,←⊂C.files[C.rankings⊃⍨C.controlsoi⊂control]
                  :Else
                      C.relevant,←Ø
                  :EndIf
     
     
              :EndFor
     
              C.reldocs←(RelDocs¨C.controls),Ø
              C.doclink←(DocLink¨C.controls),Ø
              C.used←{⊂2↓∊', '∘,¨C.doclink[C.controlsoi¨⍵]}¨C.demos
     
              C.tasks←{Link('Description'Section Read ⍵)⍵}¨C.files
     
              C.type←'simple' 'advanced' 'mini-app'[1⍳⍨¨↓⍉∨/¨'Simple' 'Advanced'∘.⍷C.files]
     
              C.filedescr,←Ø ⍝ These cause an empty result if looked-up is not found
              C.demos,←Ø
              C.rankings,←Ø
              C.descr,←Ø
              C.ctor,←Ø
              C.notes,←Ø
              C.notes,←Ø
              C.ns,←Ø
     
          :Else
              C←⍎CACHE ⍝ establish shortcut
          :EndIf
      :EndHold
    ∇

      ForControl←{ ⍝ e.g. 'notes'ForControl'DataTable'
          (C.controlsoi⊂,⍵)⊃C⍎⍺
      }
      ForFile←{ ⍝ e.g. 'filedescr'ForFile'DataTable'
          (C.filesoi⊂,⍵)⊃C⍎⍺
      }

    :ENDSECTION ⍝ ─────────────────────────────────────────────────────────────────────────────────
⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝ ⍝


:EndNamespace
