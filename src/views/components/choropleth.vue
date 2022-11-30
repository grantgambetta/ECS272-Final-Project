<template>
    <svg id="choropleth" width="800" height="400" style = "position: absolute; top: 100px;"></svg>
    <svg id="legend" width="800" height="400" style = "position: absolute; left: 800px; top: 100px;"></svg>
</template>

<script>
import * as d3 from 'd3';
import { select } from 'd3-selection';
import dataMap from "../../assets/data/countries.json"



export default {
  name: 'Choropleth',
  data() {
    return {

    };
  },
  props:{
    myMapData: Array,
  },
  mounted() {
    console.log(dataMap);
    let localData = dataMap;
    this.drawChoropleth(localData, "#choropleth") 
    console.log("Data Passed down as a Prop  ", this.myMapData)
  },
  methods:{
    drawChoropleth(data2, id) {

      // The svg
      const svg = d3.select("#choropleth"),
        width = +svg.attr("width"),
        height = +svg.attr("height");

      // Map and projection
      const path = d3.geoPath();
      const projection = d3.geoMercator()
        .scale(100)
        .center([0, 20])
        .translate([width / 2, height / 2]);
      
      // Data and color scale
      const data = new Map();
      const domain_values = [10, 100, 1000, 5000, 10000, 15000, 30000]
      const legend_keys = ['10 or less', '10 to 100', '100 to 1000', '1000 to 5000', '5000 to 10000', '10000 to 15000', '15000 to 30000']
      const colorScheme = ["#fef0d9","#fdd49e","#fdbb84","#fc8d59","#ef6548","#d7301f","#990000"]
      const colorScale = d3.scaleThreshold()
        .domain(domain_values)
        .range(colorScheme)

      
      // Load external data and boot
      Promise.all([
      d3.json("https://raw.githubusercontent.com/holtzy/D3-graph-gallery/master/DATA/world.geojson"),
      d3.csv("https://raw.githubusercontent.com/grantgambetta/ECS272-Final-Project/main/choropleth_attacks.csv", function(d) {
          data.set(d.iso3, +d.num_attacks)
      })]).then(function(loadData) {
        let topo = loadData[0]
        
          let mouseOver = function(d) {
          d3.selectAll(".Country")
            .transition()
            .duration(0)
            .style("opacity", .5)
          d3.select(this)
            .transition()
            .duration(0)
            .style("opacity", 1)
            .style("stroke", "black")
        }
      
        let mouseLeave = function(d) {
          d3.selectAll(".Country")
            .transition()
            .duration(0)
            .style("opacity", .8)
          d3.select(this)
            .transition()
            .duration(0)
            .style("stroke", "transparent")
        }
        
        console.log("HEREEE")
        console.log(topo.features)
        // Draw the map
        svg.append("g")
          .selectAll("path")
          .data(topo.features)
          .enter()
          .append("path")
            // draw each country
            .attr("d", d3.geoPath()
              .projection(projection)
            )
            // set the color of each country
            .attr("fill", function (d) {
              d.total = data.get(d.id) || 0;
              return colorScale(d.total);
            })
            .style("stroke", "transparent")
            .attr("class", function(d){ return "Country" } )
            .attr("id", d => d.properties.name)
            .style("opacity", .8)
             .on("mouseover", mouseOver )
             .on("mouseleave", mouseLeave )
      
      })

      // select the svg area
      var svg2 = d3.select("#legend")


      // Usually you have a color scale in your chart already
      // var color = d3.scaleThreshold()
      // .domain(keys)
      // .range(d3.schemeSet2);

      // const legend_color = d3.scaleThreshold()
      //   .domain(domain_values)
      //   .range(colorScheme);

      // Add one dot in the legend for each name.
      svg2.selectAll("mydots")
      .data(domain_values)
      .enter()
      .append("circle")
          .attr("cx", 100)
          .attr("cy", function(d,i){ return 100 + i*25}) // 100 is where the first dot appears. 25 is the distance between dots
          .attr("r", 7)
          .style("fill", function(d){ return colorScale(d)})

      // Add one dot in the legend for each name.
      svg2.selectAll("mylabels")
      .data(legend_keys)
      .enter()
      .append("text")
          .attr("x", 120)
          .attr("y", function(d,i){ return 100 + i*25}) // 100 is where the first dot appears. 25 is the distance between dots
          .style("fill", function(d){ return colorScale(d)})
          .text(function(d){ return d})
          .attr("text-anchor", "left")
          .style("alignment-baseline", "middle")


        // dummy rectangles to select regions
        // const svg3 = d3.select(id)
        //   .append("svg")
        //   .attr("width", 1000)
        //   .attr("height", 100);

        // const rect = svg3
        //   .append("rect")
        //   .attr("id","SouthAmerica")
        //   .attr("x", 0)
        //   .attr("y", 0)
        //   .attr("width", 400)
        //   .attr("height", 70)
        //   .text("South America")
        //   .attr("opacity",0.5)
        //   .attr("fill", "red")
        //   .on("click",(e,d,i) => {
        //     this.$emit("clicked",{'data':"SouthAmerica"})
        //   });

        // rect
        //   .append("text")
        //   .attr("x", 0)
        //   .attr("y", 0)
        //   .attr("dy", ".35em")
        //   .attr("fill","black")
        //   .text("South America");


        //   const rect2 = svg3
        //   .append("rect")
        //   .attr("id","MiddleEastNorthAfrica")
        //   .attr("x", 500)
        //   .attr("y", 0)
        //   .attr("width", 400)
        //   .attr("height", 70)
        //   .text("Middle east")
        //   .attr("opacity",0.5)
        //   .attr("fill", "blue")
        //   .on("click",(e,d,i) => {
        //     this.$emit("clicked",{'data':"MiddleEastNorthAfrica"})
        //   });



    }
  },
};
</script>