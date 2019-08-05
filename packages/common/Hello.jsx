import React from "react";

function Heading({ level = "2", title }) {
  return React.createElement(`h${level}`, {}, title);
}

export default Heading;
