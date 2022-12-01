<template>
    <svg id="choropleth" width="800" height="400" style = "position: absolute; top: 150px;"></svg>
    <svg id="legend" width="300" height="400" style = "position: absolute; left: 570px; top: 95px;"></svg>
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
        .scale(120)
        .center([0, 20])
        .translate([width / 2, height / 2]);
      
      // Data and color scale
      const data = new Map();

      /*
      in the if-else statement, for each metric need to pass in the dataset, domain values, create the legend, and create color scheme
      */
      // attacks
      const domain_values = [10, 100, 1000, 5000, 10000, 15000, 30000] 
      const attacks_data = "https://raw.githubusercontent.com/grantgambetta/ECS272-Final-Project/main/src/assets/data/map/choropleth_attacks.csv"
      const color_scheme = d3.schemeReds[domain_values.length]
      var legendBar = legend({
            color: d3.scaleThreshold(
                domain_values,
                color_scheme
            ),
            title: "Number of Attacks",
            tickSize: 0,
        });

      const csv_file = attacks_data

      // deaths
    //   const domain_values = [20, 100, 1000, 5000, 15000, 30000, 45000]
    //   const deaths_data = "https://raw.githubusercontent.com/grantgambetta/ECS272-Final-Project/main/src/assets/data/map/choropleth_deaths.csv"
    //   const color_scheme = d3.schemeReds[domain_values.length]
    //   var legendBar = legend({
    //         color: d3.scaleThreshold(
    //             domain_values,
    //             color_scheme
    //         ),
    //         title: "Number of Casualities",
    //         tickSize: 0,
    //     });
    //   const csv_file = deaths_data


      // injuries
    //   const domain_values = [30, 100, 1000, 5000, 10000, 15000, 30000, 50000, 150000]
    //   const injuries_data = "https://raw.githubusercontent.com/grantgambetta/ECS272-Final-Project/main/src/assets/data/map/choropleth_injured.csv"
    //   const color_scheme = d3.schemeReds[domain_values.length]
    //   var legendBar = legend({
    //         color: d3.scaleThreshold(
    //             domain_values,
    //             color_scheme
    //         ),
    //         title: "Number of Injuries",
    //         tickSize: 0
    //     });
    //   const csv_file = injuries_data

    // define color scale with domain values and color scheme for selected metric
      const colorScale = d3.scaleThreshold()
        .domain(domain_values)
        .range(color_scheme)

      
      // pass in selected dataset in d3.csv
      Promise.all([
      d3.json("https://raw.githubusercontent.com/holtzy/D3-graph-gallery/master/DATA/world.geojson"),
      d3.csv(csv_file, function(d) {
          data.set(d.iso3, +d.measure)
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
    //   svg2.selectAll("mydots")
    //   .data(domain_values)
    //   .enter()
    //   .append("circle")
    //       .attr("cx", 100)
    //       .attr("cy", function(d,i){ return 100 + i*25}) // 100 is where the first dot appears. 25 is the distance between dots
    //       .attr("r", 7)
    //       .style("fill", function(d){ return colorScale(d)})

    //   // Add one dot in the legend for each name.
    //   svg2.selectAll("mylabels")
    //   .data(legend_keys)
    //   .enter()
    //   .append("text")
    //       .attr("x", 120)
    //       .attr("y", function(d,i){ return 100 + i*25}) // 100 is where the first dot appears. 25 is the distance between dots
    //       .style("fill", function(d){ return colorScale(d)})
    //       .text(function(d){ return d})
    //       .attr("text-anchor", "left")
    //       .style("alignment-baseline", "middle")
    // you can store the return of the funcion

    // used the following legend code: https://observablehq.com/@d3/color-legend
    function legend({
                color,
                title,
                tickSize = 6,
                width = 400, 
                height = 44 + tickSize,
                marginTop = 18,
                marginRight = 0,
                marginBottom = 16 + tickSize,
                marginLeft = 0,
                ticks = width / 64,
                tickFormat,
                tickValues
                } = {}) {

                const svg = d3.select("#legend")
                    .attr("width", width)
                    .attr("height", height)
                    .attr("viewBox", [0, 0, width, height])
                    .style("overflow", "visible")
                    .style("display", "block");

                let tickAdjust = g => g.selectAll(".tick line").attr("y1", marginTop + marginBottom - height);
                let x;

                // Continuous
                if (color.interpolate) {
                    const n = Math.min(color.domain().length, color.range().length);

                    x = color.copy().rangeRound(d3.quantize(d3.interpolate(marginLeft, width - marginRight), n));

                    svg.append("image")
                        .attr("x", marginLeft)
                        .attr("y", marginTop)
                        .attr("width", width - marginLeft - marginRight)
                        .attr("height", height - marginTop - marginBottom)
                        .attr("preserveAspectRatio", "none")
                        .attr("xlink:href", ramp(color.copy().domain(d3.quantize(d3.interpolate(0, 1), n))).toDataURL());
                }

                // Sequential
                else if (color.interpolator) {
                    x = Object.assign(color.copy()
                        .interpolator(d3.interpolateRound(marginLeft, width - marginRight)),
                        {range() { return [marginLeft, width - marginRight]; }});

                    svg.append("image")
                        .attr("x", marginLeft)
                        .attr("y", marginTop)
                        .attr("width", width - marginLeft - marginRight)
                        .attr("height", height - marginTop - marginBottom)
                        .attr("preserveAspectRatio", "none")
                        .attr("xlink:href", ramp(color.interpolator()).toDataURL());

                    // scaleSequentialQuantile doesn’t implement ticks or tickFormat.
                    if (!x.ticks) {
                    if (tickValues === undefined) {
                        const n = Math.round(ticks + 1);
                        tickValues = d3.range(n).map(i => d3.quantile(color.domain(), i / (n - 1)));
                    }
                    if (typeof tickFormat !== "function") {
                        tickFormat = d3.format(tickFormat === undefined ? ",f" : tickFormat);
                    }
                    }
                }

                // Threshold
                else if (color.invertExtent) {
                    const thresholds
                        = color.thresholds ? color.thresholds() // scaleQuantize
                        : color.quantiles ? color.quantiles() // scaleQuantile
                        : color.domain(); // scaleThreshold

                    const thresholdFormat
                        = tickFormat === undefined ? d => d
                        : typeof tickFormat === "string" ? d3.format(tickFormat)
                        : tickFormat;

                    x = d3.scaleLinear()
                        .domain([-1, color.range().length - 1])
                        .rangeRound([marginLeft, width - marginRight]);

                    svg.append("g")
                    .selectAll("rect")
                    .data(color.range())
                    .join("rect")
                        .attr("x", (d, i) => x(i - 1))
                        .attr("y", marginTop)
                        .attr("width", (d, i) => x(i) - x(i - 1))
                        .attr("height", height - marginTop - marginBottom)
                        .attr("fill", d => d);

                    tickValues = d3.range(thresholds.length);
                    tickFormat = i => thresholdFormat(thresholds[i], i);
                }

                // Ordinal
                else {
                    x = d3.scaleBand()
                        .domain(color.domain())
                        .rangeRound([marginLeft, width - marginRight]);

                    svg.append("g")
                    .selectAll("rect")
                    .data(color.domain())
                    .join("rect")
                        .attr("x", x)
                        .attr("y", marginTop)
                        .attr("width", Math.max(0, x.bandwidth() - 1))
                        .attr("height", height - marginTop - marginBottom)
                        .attr("fill", color);

                    tickAdjust = () => {};
                }

                svg.append("g")
                    .attr("transform", `translate(0,${height - marginBottom})`)
                    .call(d3.axisBottom(x)
                        .ticks(ticks, typeof tickFormat === "string" ? tickFormat : undefined)
                        .tickFormat(typeof tickFormat === "function" ? tickFormat : undefined)
                        .tickSize(tickSize)
                        .tickValues(tickValues))
                    .call(tickAdjust)
                    .call(g => g.select(".domain").remove())
                    .call(g => g.append("text")
                        .attr("x", marginLeft)
                        .attr("y", marginTop + marginBottom - height - 6)
                        .attr("fill", "currentColor")
                        .attr("text-anchor", "start")
                        .attr("font-weight", "bold")
                        .text(title))
                        .style("font-size", "14px");

                return svg.node();
                }

                function ramp(color, n = 256) {
                const canvas = DOM.canvas(n, 1);
                const context = canvas.getContext("2d");
                for (let i = 0; i < n; ++i) {
                    context.fillStyle = color(i / (n - 1));
                    context.fillRect(i, 0, 1, 1);
                }
                return canvas;
            }

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