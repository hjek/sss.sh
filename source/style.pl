:- module(style, [style/2]).

style(shartphone,Style) :-
  Style = "


body, summary, input, textarea, select {
  font-family: mononoki, Monospace;
  background: black;
  color: lime;
}


summary, input, textarea, select {
  transition-duration: 1s;
  color: lime;
}

select {
  -webkit-appearance: none;
  -moz-appearance: none;
}

::selection {
  color: black;
  background: lime;
}

textarea, input, select {
  border: 1px solid green;
  margin: 5px;
}

textarea {
  width: 100%;
  resize: vertical;
}

fieldset {
  border: 1px solid lime;
  margin: 5px;
}

summary:hover, input:hover, select:hover {
  color: white;
  transition-duration: 0s;
}

".
