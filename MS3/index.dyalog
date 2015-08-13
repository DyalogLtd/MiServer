﻿:Class index : MiPageSample

    :SECTION GLOBALS ⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝

    :Field TYPES←'Simple' 'Advanced' 'Dyalog' ⍝ Types of samples (if not App)
    :Field GROUPS←'Base HTML' 'Dyalog Controls' 'JQueryUI' 'SyncFusion' ⍝ Names of groups of elements
    :Field REFS        ⍝ ... their refs
    :Field APPS        ⍝ List of all apps
    :Field SAMPLES     ⍝ List of all samples (well, groups and controls really)
    :Field INFOLONG    ⍝ Long desc of each control
    :Field INFOSHORT   ⍝ Short (1-3 words) desc of each control
    :Field NAMESLONG   ⍝ Elements that have long info
    :Field NAMESSHORT  ⍝ Elements that have short info
    :Field SEARCH←''   ⍝ Last-search cache
    :Field CONTROLS←'' ⍝ All control names
    :Field APPDESCS    ⍝ Sample Apps' Description::
    :Field APPCTRLS    ⍝ Sample Apps' Control:: (i.e. the title)
    :Field SPEEDUP←0   ⍝ Use pregenerated JS to speed up

    :ENDSECTION

    :SECTION UTILITIES ⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝

    Q←'"'∘,,∘'"'  ⍝ Surround with quotes, a.k.a. APL dragon

    D←{(×≢⍵)/' – ',⍵} ⍝ Prepend a dash if non-empty

    P←{1⌽(×≢#.HTMLInput.dtlb ⍵)/') (',⍵} ⍝ Surround with parens if non-empty

    Words←{(1↓¨(' '∘=⊂⊢)' ',⍵)~⊂''} ⍝ Split at spaces

    SpaceToDir←{'Examples/',1↓⍵} ⍝ Convert Space name to Folder name

    Frame←{'.framed' ('src=',Q⍵,'?NoWrapper=1') New _.iframe}

    NewWinA←{('target' '_blank')('href=',Q⊃⌽⍵) New _.a (⊃⍵)} ⍝ New link that opens in a new window/tab

    NewDiv←{⍵ New _.div} ⍝ Make a div

    Horz←{⍺←⊢ ⋄ r⊣(r←⍺ New _.StackPanel ⍵).Horizontal←1} ⍝ Horizontal StackPanel

    Type←{P(1⍳⍨∨/¨TYPES⍷¨⊂⍵)⊃TYPES,⊂'App'} ⍝ Simple/Advanced/App?

    Dread←{0::,⊂'[file read failed]' ⋄ #.UnicodeFile.ReadNestedText #.Boot.AppRoot,⍵,'.dyalog'} ⍝ Read dyalog file

    Dlist←{0::⍬ ⋄ ¯7↓¨6⊃#.Files.DirX #.Boot.AppRoot,⍵,'/*.dyalog'} ⍝ List dyalog files

    NodeID←{⍺←⊢ ⋄ ('#node',⊃⍵)∘,¨⍕¨⍺+⍳⍴⊃⌽⍵} ⍝ Generate node ids (⍵='L' items) optional (⍺=offset)

    In←{∨/¨⊃⍷¨/{⎕SE.Dyalog.Utils.lcase¨eis ⍵}¨⍺ ⍵} ⍝ Case-insensitive find

    Names←{1↓¨⍵↑¨⍨¯1+⍵⍳¨':'} ⍝ Extract section names from set of several 'name:: description'

    AddShortInfo←{⍵,¨P¨(4+⍴¨⍵)↓¨(INFOSHORT,⊂'')[NAMESSHORT⍳⍵]} ⍝ ⍵ (ShortDesc)
                    ⍝(⍵∊NAMESSHORT)/¨
    AddLongInfo←{⍵,¨D¨{⍵,'[no info available]'/⍨0∊⍴⍵}¨(4+⍴¨⍵)↓¨(INFOLONG,⊂'')[NAMESLONG⍳⍵]} ⍝ ⍵ - LongDesc

      Section←{ ⍝ extract section ⍺:: from code ⍵
          regex←'^\s*⍝\s*',⍺,':(:.*?)$((\R^⍝(?!\s*\w+::).*?$)*)'
          opts←('Mode' 'M')('DotAll' 1)
          res←(regex ⎕S'\1\2'⍠opts)⍵
          (1↓⊃res)~'⍝'
      }

      JSsafe←{ ⍝ Make text JS safe by escaping problematic chars
          fr←'''' '"' '\\' '\n' '\r',⎕UCS 9 8 12               ⍝ ' " \ NL CR TB BS FF
          to←'\\''' '\\"' '\\\\' '\\n' '\\r' '\\t' '\\b' '\\f' ⍝ problematic in regex too :-)
          Q(fr ⎕R to⍠'Mode' 'D')⍵ ⍝ Replace problematic chars and sourround with quotes
      }

    ∇ js←APLtoJS vtv;act;data
      :Access public shared
     ⍝ Convert vectors of pseudo JS (generated by Replace, Execute, et al.) to proper JS
     
      js←''
      :For act data :In eis vtv
          data←JSsafe⊃⌽eis data ⍝ the last or only one
          :Select ⊃eis act      ⍝ the first or only one
          :Case 'assign'
              js,←(⊃⌽act),' = ',data,';' ⍝ variable = "data"
          :Case 'execute'
              js,←'eval(',data,');' ⍝ eval("data")
          :Case 'replace'
              js,←'$("',(⊃⌽act),'").html(',data,');' ⍝ $("#myid").html("data")
          :Else
              js,←'$("',(⊃⌽act),'").',(⊃act),'(',data,');' ⍝ $("#myid").append("data")
          :EndSelect
      :EndFor
    ∇

    ∇ Speedup;p;r
      (p←'node0'New _html.p'1').On'click' 'On2'
      r←p.Render
      ⍎('\A' '0' '1' '2' '\z'⎕R'NodeOn←{id←(⊃⍵),⍕⊃⌽⍺ ⋄ cont←⊃⍺ ⋄ ''' ''',id,''' ''',cont,''' ''',⍵,''' '''}'⍠'Mode' 'D')r
    ∇

    :ENDSECTION

    :SECTION MAIN ⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝

    ∇ Compose;left;mid;right;sp;style
      :Access public
     
     ⍝ Initialize globals
      SAMPLES←0 3⍴⍬
      REFS←_html _DC _JQ _SF
      INFOSHORT←'⍝',¨Dread'Examples/Data/infoShort'
      INFOLONG←'⍝',¨Dread'Examples/Data/infoLong'
      NAMESSHORT←Names INFOSHORT
      NAMESLONG←Names INFOLONG
     ⍝ Use'ejTab' ⍝ May get added by callbacks
     
      '#title'Add _.title'MS3: About' ⍝ After the : will be updated
     
      Add _.StyleSheet'/Styles/homepage.css'
      style←''
      style,←'#leftBar {background-color:inherit;margin-right:6px;}'
      style,←'.menu {margin-bottom:0pt;width:110px;padding-left:0;padding-right:0;}'
      style,←'.submenu {max-height:75px;overflow-y:scroll;background-color:white;border:2px groove threedface;}'
      style,←'.menuitem {margin-bottom:0;margin-left:0px;padding-left:2px;cursor:pointer;} '
      style,←'.menuitem:hover {background-color:lightblue;} '
      style,←'.framed {width:980px;max-height:600px;min-height:400px;border:2px inset;overflow-y:auto;background-color:white;;} '
      style,←'.listitem {margin:8px;cursor:pointer;outline:darkblue auto 5px;padding-left:2px;padding-right:2px}'
      style,←'.listitem:hover {background-color:lightblue;}'
      style,←'.samplesource {overflow-x:auto;background-color:#e5e5cc;border:2px inset;}'
      Add _.style style
     
      (left mid)←NewDiv¨'#leftBar' '#midBar' ⍝ Create panes
      sp←'mainSP'Add _.StackPanel left mid  ⍝ Left is now in top
     ⍝ sp.Items[1].style←⊂'width: 200px; max-height: 450px;'
      ⍝sp.Items[2].style←⊂'margin: 5px;'
      sp.style←'height: 450px;background-color:inherit;'
     
      PopulateLeft left
      PopulateMid mid
    ∇

    ∇ PopulateLeft thediv;class;depths;group;items;names;ref;samples;vp;search;style;menu;i;fs;ac;text
     
      stuff←''
     
     
      ⍝ SAMPLE APPS ⍝⍝⍝
      APPS←(Dlist'Examples/Apps')~⊂'index'
      APPDESCS←(⊂'Description')Section¨Dread¨'Examples/Apps/'∘,¨APPS
      APPCTRLS←(⊂'Control')Section¨Dread¨'Examples/Apps/'∘,¨APPS
      text←New _.b
      text.Add¨'Sample'_.br'Apps'
      (stuff,←'#nodeA0' '.menu'New _.button'<b>Sample<br>Apps</b>').On'click' 'OnApp'
      :For (group ref i) :InEach GROUPS REFS(⍳⍴GROUPS)
          names←{({#.HtmlElement=⊃⊃⌽⎕CLASS ⍵}¨⍵)/⍵}ref.(⍎¨⎕NL ¯9.4)
          class←2↓⍕ref              ⍝ Remove leading #.
          names←(3+⍴class)↓¨⍕¨names ⍝ Remove leading #.class.
          CONTROLS,←⊂names
          text←New _.span
          text.Add¨(_.b class)_.br(_.small group)
          (stuff,←('#nodeM',⍕i)'.menu'New _.button text).On'click' 'OnClass'
      :EndFor
     
      ⍝ SEARCH FIELD ⍝⍝⍝
      (stuff,←'style="margin-top:8px"'New _.EditField'str').On'change' 'OnSearch'('str' 'val')
      text←New _.b
      text.Add¨'Search'_.br'samples'
      (stuff,←'#case' '.menu'New _.button text).On'click' 'OnSearch'
     
      thediv.Add Horz stuff
      thediv.Add _.hr
    ∇

    ∇ PopulateMid mid;url;code;frame;mya
     
     ⍝ Read framed pages
      url←'Examples/Apps/About'
      code←Dread url
     ⍝ Create and fill placeholder for title header
      mya←('#SampleTitle'mid.Add _.h2).Add NewWinA('Control'Section code)url
     ⍝ Create and fill placeholder for description line
      '#SampleDesc'mid.Add _.p('Description'Section code)
     ⍝ Create and fill placeholder for embedded page
      frame←mid.Add NewDiv'#SampleFrame'
      frame.Add Frame url
      '#SampleSource' '.samplesource'mid.Add _.div,⊂'x-small;border:none'#.HTMLInput.APLToHTMLColour code
    ∇

    :ENDSECTION

    :SECTION CALLBACKS ⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝

    ∇ r←OnApp;node;descs;out;items;time;title;i
      :Access Public
     ⍝ Gets called upon selection in Sample Apps tree
      :If ×node←⍎5↓_what ⍝ ≥1 is an actual app id="nodeA23"
          r←Update'Examples/Apps/',node⊃APPS
      :Else ⍝ =0 is the header
          descs←APPCTRLS,¨' – '∘,¨APPDESCS
          out←NewDiv'.framed'
          items←(NodeID'A'APPS)out.Add¨_.p,¨descs
          items.Set⊂'.listitem'
          items.On⊂'click' 'OnApp'
          r←'Apps' 'Small applications to showcase MiServer 3.0 functionality'(' apps',⍨≢APPS)out''
      :EndIf
      r←GenJS r
    ∇

    ∇ r←OnClass;descs;out;items;name;node
      :Access Public
      node←⍎5↓_what ⍝ id="nodeM23"
      CURRCTRLS←node⊃CONTROLS
      descs←AddLongInfo CURRCTRLS
      out←NewDiv'.framed'
      :If SPEEDUP
          Speedup
          (descs,¨⍳⍴CURRCTRLS)NodeOn¨⊂'Control'
      :Else
          items←(NodeID'C'CURRCTRLS)out.Add¨_.p,¨descs
          items.Set⊂'.listitem'
          items.On⊂'click' 'OnControl'
      :EndIf
      CURRSPACE←2↓⍕node⊃REFS
      r←GenJS CURRSPACE('Members of ',2↓CURRSPACE,P node⊃GROUPS)(' controls',⍨⍕⍴CURRCTRLS)out''
    ∇

    ∇ r←OnControl;node;control;spacectrl;spacedir;files;out;url;code;ctrlsec;desc;iframe;title;item;i;file
      :Access Public
      node←⍎5↓_what ⍝ id="nodeC23"
      control←node⊃CURRCTRLS
      spacectrl←CURRSPACE,'.',control
      spacedir←SpaceToDir CURRSPACE
      files←Dlist spacedir
      out←NewDiv'.framed'
      CURRFILES←''
      CURRDESCS←''
      i←0
      :For file :In files
          url←spacedir,'/',file
          code←Dread url
          ctrlsec←'Control'Section code
          :If (⊂spacectrl)∊Words ctrlsec ⍝ Extract space-separated words
              i+←1
              CURRFILES,←⊂url
              desc←⊂'Description'Section code
              desc←∊desc,Type file
              CURRDESCS,←⊂desc
              item←('#nodeS',⍕i)'.listitem'out.Add _.p desc
              item.On'click' 'OnSample'
          :EndIf
      :EndFor
      title←1↓control Section INFOSHORT
      title←'Samples using ',2↓spacectrl,P title
      desc←control Section INFOLONG
      r←GenJS spacectrl title desc out''
    ∇

    ∇ r←OnSample
      :Access Public
      r←GenJS Update CURRFILES⊃⍨⍎5↓_what ⍝ id="nodeS23"
    ∇

    ∇ r←OnSearch;time;str;terms;out;i;dir;files;file;url;code;ctrlsec;desc;item
      :Access Public
      time←0.001×3⊃⎕AI ⍝ prepare search statistics
      :If ×≢str←Get'str'  ⍝ get search string
      ⍝⍝⍝ Controls
          terms←INFOSHORT/⍨str In INFOSHORT
          terms,←terms~⍨INFOLONG/⍨str In INFOLONG
          terms←'.',¨∪Names terms
      ⍝⍝⍝ Samples
          out←NewDiv'.framed'
          CURRFILES←''
          CURRDESCS←''
          i←0
          :For dir :In 'Apps' 'html' 'HTMLplus' 'DC' 'JQ' 'SF'
              files←Dlist'Examples/',dir
              :For file :In files~⊂'index'
                  url←'Examples/',dir,'/',file
                  code←Dread url
                  ctrlsec←'Control'Section code
                  desc←⊂'Description'Section code
                  :If ∨/str In desc
                  :OrIf ∨/∊(terms,⊂str)⍷¨⊂ctrlsec ⍝ always case sensitive
                      i+←1
                      CURRFILES,←⊂url
                      desc←∊desc,Type file
                      CURRDESCS,←⊂desc
                      item←('#nodeS',⍕i)'.listitem'out.Add _.p desc
                      item.On'click' 'OnSample'
                  :EndIf
              :EndFor
          :EndFor
          desc←New _.span'Showing results for '
          desc.Add _.em str
          desc.Add(×≢terms)/D'including relevant element','s'/⍨1≠≢terms
          desc.Add _.em(⍕1↓¨terms)
          SEARCH←(Q str)''desc out''
      :EndIf
      time-⍨←0.001×3⊃⎕AI
      (2⊃SEARCH)←(⍕≢CURRFILES),' results (',time,' seconds)'
      r←GenJS SEARCH
     
    ∇

    ∇ (page title desc iframe code)←Update url;ctrlsec
     ⍝ Create new placeholder values
      page←'MS3: Sample'
      iframe←Frame url
      code←Dread url
      ctrlsec←'Control'Section code
      desc←'Description'Section code
      title←NewWinA ctrlsec url
     
    ∇

    ∇ r←GenJS(page title desc iframe code)
     ⍝ Generate JavaScript for filling placeholders
      r←'#title'Replace'MS3: ',page
      r,←'#SampleTitle'Replace title
      r,←'#SampleDesc'Replace desc
      r,←'#SampleFrame'Replace iframe
      r,←'#SampleSource'Replace(×≢code)/'x-small;border:none'#.HTMLInput.APLToHTMLColour code
    ∇

    :ENDSECTION

:EndClass