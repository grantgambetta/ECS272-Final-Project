<template>
    <div id="sankey"></div>
</template>

<script>
import * as d3 from 'd3';
import { sankey, sankeyLinkHorizontal } from 'd3-sankey';
import dataSankey from "../../assets/data/sankey.json"
// import dataSankeyDetail from "../../assets/data/fire_sankey_detail.json"
// import dataSankeyDetailYear from "../../assets/data/fire_sankey_detailYear.json"

export default {
  name: 'Sankey',
  data() {
    return {

    };
  },
  props:{
    mySankeyData: Array,
  },
  mounted() {
    console.log(dataSankey);
    //let localData = dataSankey['data'];
    let localData=dataSankey["items"];
    // let localDataDetail=dataSankeyDetail["items"];
    // let localDataDetailYear=dataSankeyDetailYear["items"]; 
    this.drawSankey(localData, "#sankey") 
    console.log("Data Passed down as a Prop  ", this.mySankeyData)
  },
  methods:{
    drawSankey(data, id) {
        // https://stackblitz.com/edit/vue-unqnbj?file=src%2Fcomponents%2FUI.vue
        // const { items } = this;

        // console.log("Width is "+Element.clientWidth())

        var margin = {top: 10, right: 10, bottom: 10, left: 10},
        width = 1520 - margin.left - margin.right,
        height = 470 - margin.top - margin.bottom;
        
        const nodeWidth = 80;
        const nodeHeight = 60;
        const nodePadding = 10;

        const ENABLE_LINKS_GRADIENTS = false;
        
        // Colors Legend
        // color generator: https://observablehq.com/@d3/color-schemes 
        // (can modify the code to generate 24 discrete categories)
        const regions=["Middle East & North Africa","South Asia","South America","Sub-Saharan Africa",
                        "Western Europe","Southeast Asia","Central America & Caribbean","Eastern Europe",
                        "North America","East Asia","Central Asia","Australasia & Oceania"]
        const color_regions=["#e6ab02","#1b9e77","#d95f02","#66a61e",
                    "#e7298a","#666666","#a6761d","#7570b3",
                    "#33a02c","#fdbf6f","#1f78b4","#000000"]
        const countries=["Iraq","Turkey","Yemen","Algeria",
                         "Egypt","Lebanon","Libya","West Bank and Gaza Strip",
                         "Syria","Israel","Iran","Other"]
        const color_countries=["#fcb59b","#fca082","#fc8a6b","#fb7455",
                               "#f75d43","#ef4533","#e23028","#d01f20",
                               "#bb151a","#a40f16","#870811","#67000d"].reverse()  // scale of red
        const method=["Bombing/Explosion","Armed Assault","Assassination","Hostage Taking",
                        "Facility/Infrastructure Attack","Unknown","Unarmed Assault","Hijacking"]
        const color_method=[ "#1f77b4","#ff7f0e","#2ca02c","#d62728",
                             "#9467bd","#8c564b","#e377c2","#7f7f7f"]
        const group_years=["1970-1974","1975-1979","1980-1984","1985-1989","1990-1994",
                      "1995-1999","2000-2004","2005-2009","2010-2014","2015-2017"]
        const color_years=[ "#076d2e","#076d2e","#076d2e","#076d2e","#076d2e",
                            "#076d2e","#076d2e","#076d2e","#076d2e","#076d2e"] // same color so it does not convey more information
        const target=["Private Citizens & Property","Military","Police",
                      "Business, Utilities & Communication","Unknown, religious & militia",
                      "Government","Transportation"]
        const color_target=["#1b9e77","#d95f02","#7570b3","#e7298a",
                            "#66a61e","#e6ab02","#a6761d"] 
        const source=["START Primary Collection","PGIS","CETIS","ISVG","Other Source"]
        const color_source=["#4e79a7","#f28e2c","#e15759","#76b7b2","#59a14f"]

        const causes = group_years.concat(countries,method,target,source)
        const color = d3.scaleOrdinal()
            .domain(causes)
            .range(color_years.concat(color_countries,color_method,
                          color_target,color_source))   


        const svg = d3
        .select(id).append("svg")
        // .select(this.$refs.svg)
        .attr('width',width)
        .attr('height',height)
        .attr('viewBox', [0, 0, width, height ]);

        // height scale
        const h = d3.scaleLinear()
                    .domain([0, d3.max(data.nodes, d => d.value)]).nice()
                    .rangeRound([0, nodeHeight*3.25]); // MAGIC NUMBER TO MAKE EVERYTHING SCALE

       /* const s = sankey()
        .nodeId((d) => d.name)
        .nodeWidth(nodeWidth)
        .nodePadding(nodePadding)
        .extent([
            [1, 1],
            [width, height],
        ])(data); // this line is key, it passes the data from JSON to the render display
*/

                //////////
        // HIGHLIGHT GROUP //
        //////////
        

        // What to do when one group is hovered
        
        var freezeHighlight=false // if click event, then we freeze the current highlight
        const highlight = function(event,d){
          if (!freezeHighlight){// if click then freeze
            // reduce opacity of all groups
            d3.selectAll(".myNode").style("opacity", .1)
            d3.selectAll(".myLink").style("opacity", .1)
            // expect the one that is hovered
            // console.log(d.id)
            let query = document.querySelector('.sankey-'+d.id) // query to get the x position of the node
            // console.log(query.getAttribute('x'))
  
            // opacity 1 for nodes in other columns
            d3.selectAll(".myNode")
            .filter(function() {
              return d3.select(this).attr("x") != query.getAttribute('x'); // filter by single attribute - not in the same column as the selected node
                })
              .style("opacity", 1)
  
            // opacity 1 for the node and links
            d3.select(".sankey-"+d.id).style("opacity", 1)
            d3.selectAll(".sankeyLink-"+d.id).style("opacity", 1)
            d3.selectAll(".sankeyLinkTarget-"+d.id).style("opacity", 1)
  
            // opacity 1 for link with detail
            // d3.selectAll(".sankeyLinkDetail-"+d.id).style("opacity", 1)
          } 
          
        }


        // And when it is not hovered anymore
        const noHighlight = function(event,d){
          if (!freezeHighlight){ // if click then freeze
            d3.selectAll(".myNode").style("opacity", 1)
            d3.selectAll(".myLink").style("opacity", 1)
            // d3.selectAll(".myDetailLink").style("opacity", 0) // invisible links behind
          }
        }
        
        const mouseClick = function(event,d){
          if (freezeHighlight){
            freezeHighlight=false
          } else {
            freezeHighlight=true
          }
        }
        //////////


        const { nodes, links} = sankey()
        .nodeId((d) => d.name)
        .nodeWidth(nodeWidth)
        .nodePadding(nodePadding)
        .nodeSort((d) => d.node)
        .linkSort((d) => d.index)
        .extent([
            [1, 1],
            [width, height - nodeHeight],
        ])(data); // this line is key, it passes the data from JSON to the render display


        svg
        .append('g')
        .attr('stroke', '#000')
        .attr('stroke-width', '0')
        .selectAll('rect')
        .data(nodes)
        .join('rect')
        .attr("class", function(d) { return "myNode sankey-" + d.id })
        .attr('x', (d) => d.x0)
        .attr('y', (d) => d.y0)
        // .attr('height', (d) => nodeHeight)
        .attr('height', (d) => h(d.value))
        .attr('width', (d) => d.x1 - d.x0)
        .style('fill', (d) => color(d.name))
        .on("mouseover", highlight)
        .on("mouseleave", noHighlight)
        .on("click",mouseClick)
        .append('title')
        .text((d) => `${d.name}\n${d.value} number of attacks`);

        const link = svg
        .append('g')
        .attr('fill', 'none')
        .attr('stroke-opacity', 0.5)
        .selectAll('g')
        .data(links)
        .join('g');

        if (ENABLE_LINKS_GRADIENTS) {
        const gradient = link
            .append('linearGradient')
            .attr('id', (d) => (d.uid = `${d.source.id}-to-${d.target.id}`))
            .attr('gradientUnits', 'userSpaceOnUse')
            .attr('x1', (d) => d.source.x1)
            .attr('x2', (d) => d.target.x0);

        gradient
            .append('stop')
            .attr('offset', '0%')
            .attr('stop-color', (d) => color(d.source.name));

        gradient
            .append('stop')
            .attr('offset', '100%')
            .attr('stop-color', (d) => color(d.target.name));
        }

        link
        .append('path')
        .attr('d', sankeyLinkHorizontal())
        .attr("class", function(d) { return "myLink sankeyLink-" + d.source.name.replaceAll(" ","-").replaceAll("/","-").replaceAll("&","-").replaceAll(",","-")})
        // .attr("class", function(d) { return "myLink sankeyLinkTarget-" + d.target.name })
        .attr('stroke', (d) =>
            !ENABLE_LINKS_GRADIENTS ? color(d.source.name) : `url(#${d.uid})`
        )
        // .attr('stroke',(d) => color(d.source.name))
        .attr('stroke-width', (d) => Math.max(1, d.width));


        // USE TWO LINKS TO CHANGE OPACITIY
        link
        .append('path')
        .attr('d', sankeyLinkHorizontal())
        .attr("class", function(d) { return "myLink sankeyLinkTarget-" + d.target.name.replaceAll(" ","-").replaceAll("/","-").replaceAll("&","-").replaceAll(",","-")})
        // .attr("class", function(d) { return "myLink sankeyLinkTarget-" + d.target.name })
        .attr('stroke', (d) =>
            !ENABLE_LINKS_GRADIENTS ? color(d.source.name) : `url(#${d.uid})`
        )
        // .attr('stroke',(d) => color(d.source.name))
        .attr('stroke-width', (d) => Math.max(1, d.width));


        link
        .append('title')
        .text((d) => `${d.source.name} → ${d.target.name}\n${d.value} number of attacks`);

        svg
        .append('g')
        .attr('font-family', 'sans-serif')
        .attr('font-size', 12)
        .selectAll('text')
        .data(nodes)
        .join('text')
        .attr('x', (d) => d.x0 + 8)
        .attr('y', (d) => (d.y1 + d.y0) / 2)
        .attr('dy', '0.35em')
        .attr('text-anchor', 'start')
        .text((d) => d.name)
        .on("mouseover", highlight)
        .on("mouseleave", noHighlight);


        // ADD INVISIBLE LINKS TO SHOW DETAIL FOR CAUSES HISTORY - BASED ON DATA LOCAL DETAIL
        // const sankeyDetail=sankey()
        //   .nodeId((d) => d.name)
        //   .nodeWidth(nodeWidth)
        //   .nodePadding(nodePadding)
        //   .nodeSort((d) => d.node)
        //   .linkSort((d) => d.index)
        //   .extent([
        //       [1, 1],
        //       [width, height - nodeHeight],
        //   ])(data_detail);

        // const linksDetail=sankeyDetail.links
        
        // const linkDetail = svg
        //   .append('g')
        //   .attr('fill', 'none')
        //   .attr('stroke-opacity', 0.5)
        //   .selectAll('g')
        //   .data(linksDetail)
        //   .join('g');

        // if (ENABLE_LINKS_GRADIENTS) {
        //   const gradientDetail = linkDetail
        //     .append('linearGradient')
        //     .attr('id', (d) => (d.uid = `${d.source.id}-to-${d.target.id}`))
        //     .attr('gradientUnits', 'userSpaceOnUse')
        //     .attr('x1', (d) => d.source.x1)
        //     .attr('x2', (d) => d.target.x0);

        //   gradientDetail
        //     .append('stop')
        //     .attr('offset', '0%')
        //     .attr('stop-color', (d) => color(d.source.name));

        //     gradientDetail
        //       .append('stop')
        //       .attr('offset', '100%')
        //       .attr('stop-color', (d) => color(d.target.name));
        // }

        // linkDetail
        // .append('path')
        // .attr('d', sankeyLinkHorizontal())
        // .attr("class", function(d) { return "myDetailLink sankeyLinkDetail-" + d.cause.replaceAll(" ","-").replaceAll("/","-")})
        // // .attr("class", function(d) { return "myLink sankeyLinkTarget-" + d.target.name })
        // .attr('stroke', (d) =>
        //     !ENABLE_LINKS_GRADIENTS ? color(d.cause) : `url(#${d.uid})`
        // )
        // // .attr('stroke',(d) => color(d.source.name))
        // .attr('stroke-width', (d) => Math.max(1, d.width))
        // .style("opacity", 0);

        // linkDetail
        // .append('title')
        // .text((d) => `${d.cause}\n${d.source.name} → ${d.target.name}\n${d.value} thousands acres burned`);

        // // ADD INVISIBLE LINKS FOR CAUSE-SEASON
        // // ADD INVISIBLE LINKS TO SHOW DETAIL FOR CAUSES HISTORY - BASED ON DATA LOCAL DETAIL
        // const sankeyDetailYear=sankey()
        //   .nodeId((d) => d.name)
        //   .nodeWidth(nodeWidth)
        //   .nodePadding(nodePadding)
        //   .nodeSort((d) => d.node)
        //   .linkSort((d) => d.index)
        //   .extent([
        //       [1, 1],
        //       [width, height - nodeHeight],
        //   ])(data_detail_year);

        // const linksDetailYear=sankeyDetailYear.links
        
        // const linkDetailYear = svg
        //   .append('g')
        //   .attr('fill', 'none')
        //   .attr('stroke-opacity', 0.5)
        //   .selectAll('g')
        //   .data(linksDetailYear)
        //   .join('g');

        // if (ENABLE_LINKS_GRADIENTS) {
        //   const gradientDetail = linkDetailYear
        //     .append('linearGradient')
        //     .attr('id', (d) => (d.uid = `${d.source.id}-to-${d.target.id}`))
        //     .attr('gradientUnits', 'userSpaceOnUse')
        //     .attr('x1', (d) => d.source.x1)
        //     .attr('x2', (d) => d.target.x0);

        //   gradientDetail
        //     .append('stop')
        //     .attr('offset', '0%')
        //     .attr('stop-color', (d) => color(d.source.name));

        //     gradientDetail
        //       .append('stop')
        //       .attr('offset', '100%')
        //       .attr('stop-color', (d) => color(d.target.name));
        // }

        // linkDetailYear
        // .append('path')
        // .attr('d', sankeyLinkHorizontal())
        // .attr("class", function(d) { return "myDetailLink sankeyLinkDetail-" + d.year.replaceAll(" ","-").replaceAll("/","-")})
        // // .attr("class", function(d) { return "myLink sankeyLinkTarget-" + d.target.name })
        // .attr('stroke', (d) =>
        //     !ENABLE_LINKS_GRADIENTS ? color(d.source.name) : `url(#${d.uid})`
        // )
        // // .attr('stroke',(d) => color(d.source.name))
        // .attr('stroke-width', (d) => Math.max(1, d.width))
        // .style("opacity", 0);

        // linkDetail
        // .append('title')
        // .text((d) => `${d.cause}\n${d.source.name} → ${d.target.name}\n${d.value} thousands acres burned`);


        //

    }
  },
};
</script>