<template>
    <svg id="choropleth" width="800" height="400" style = "position: absolute; top: 150px;"></svg>
    <svg id="legend" width="300" height="400" style = "position: absolute; left: 570px; top: 95px;"></svg>
</template>

<script>
import * as d3 from 'd3';
import * as d3_selection from 'd3-selection';
import dataMap from "../../assets/data/countries.json";


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

      const vueThis = this

      // define the svg
      const svg = d3.select("#choropleth"),
        width = +svg.attr("width"),
        height = +svg.attr("height");

        // add tooltip
    const tooltip = d3.select("body").append("div")
        .attr("class", "tooltip")
        .style("opacity", 0);

      // Map and projection
      const path = d3.geoPath();
      const projection = d3.geoMercator()
        .scale(120)
        .center([0, 20])
        .translate([width / 2, height / 2]);
      
      // Data and color scale
      const data = new Map();

      // attacks
      var domain_values = [10, 100, 1000, 5000, 10000, 15000, 30000] 
      const legend_values = ['10', '100', '1000', '5000', '10K', '15K', '30K']
      var color_scheme = d3.schemeReds[domain_values.length]
      var legendBar = legend({
            color: d3.scaleThreshold(
                legend_values,
                color_scheme
            ),
            title: "Number of Attacks",
            tickSize: 0,
        });

      var csv_file = "https://raw.githubusercontent.com/grantgambetta/ECS272-Final-Project/main/src/assets/data/map/choropleth_attacks.csv"

      var selectedReg="world"

    // define color scale with domain values and color scheme for selected metric
      const colorScale = d3.scaleThreshold()
        .domain(domain_values)
        .range(color_scheme)

      
      // pass in selected dataset in d3.csv
      
      const drawMap=function(path_map){

        
      Promise.all([
      d3.json("https://raw.githubusercontent.com/holtzy/D3-graph-gallery/master/DATA/world.geojson"),
      d3.csv(path_map, function(d) {
          data.set(d.iso3, +d.measure)
        })]).then(function(loadData) {
          let topo = loadData[0]
        
        var freeze=false // if click event, then we freeze the current highlight
        
        let mouseOver = function(d) {
          if (!freeze){
            d3.selectAll(".Country")
            .transition()
            .duration(0)
            .style("opacity", .5)
          d3.select(this)
            .transition()
            .duration(0)
            .style("opacity", 1)
            .style("stroke", "black")
        //  tooltip.style("left", (d3_selection.event.pageX + 15) + "px")
		// 	.style("top", (d3_selection.event.pageY - 28) + "px")
		// 	.transition().duration(400)
		// 	.style("opacity", 1)
		// 	.text(d.properties.name + ': ' + Math.round((d.total / 1000000) * 10) / 10 + ' mio.');
            }
        }
      
        let mouseLeave = function(d) {
          if (!freeze){
            d3.selectAll(".Country")
              .transition()
              .duration(0)
              .style("opacity", .8)
              .style("stroke", "transparent")
            d3.select(this)
            .transition()
            .duration(0)
            .style("stroke", "transparent")
          }
        }

        const mouseClick = function(event,d){
          // change freeze condition
          if (freeze){
            freeze=false
            selectedReg="world"
            vueThis.$emit("clicked",{'data':'world'})
          } else {
            freeze=true
            
            selectedReg = d3.select(this).attr('region')
            console.log(selectedReg)
            
            // change storke for all selected region
            d3.selectAll(".Country")
            .filter(function() {
              return d3.select(this).attr("region") == selectedReg; // filter by single attribute
                })
                .style("opacity", 1)
                .style("stroke", "black")
            
            vueThis.$emit("clicked",{'data':selectedReg})
          }

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
            .attr("id", d => d.id)
            .style("opacity", .8)
            .on("mouseover", mouseOver )
            .on("mouseleave", mouseLeave )
            .on("click",mouseClick)

             // add key from country to region
             const csv_keyCountryRegion_path ="https://raw.githubusercontent.com/grantgambetta/ECS272-Final-Project/main/src/assets/data/country_region.csv"
              d3.csv(csv_keyCountryRegion_path).then((keyRegion) => {
                let dictionary = Object.assign({}, ...keyRegion.map((x) => ({[x.iso3]: x.region_txt.replaceAll(" ","").replaceAll("/","").replaceAll("&","").replaceAll(",","")})));
                // console.log(dictionary)
                svg
                  .selectAll("path")
                  .attr("region",d => dictionary[d.id])
              })

            //   // keep region selected while changing metric
            // if (regionText!="world"){
            //   console.log("DEBUDDGGG "+selectedReg)
            //   d3.selectAll(".Country")
            //     .style("opacity", .8)
            //     .style("stroke", "transparent")
            //     .attr("color","black")
            //     // change storke for all selected region
            //   d3.selectAll(".Country")
            //     .filter(function() {
            //       return d3.select(this).attr("region") == selectedReg; 
            //     })
            //     .style("opacity", 1)
            //     .style("stroke", "black")
            //     freeze=true;
            //   }

          })
        }

        drawMap(csv_file);
        
      
        
        d3.select("#metric").on("change",function(d){
          
          d3.select("#choropleth").selectAll('path').remove(); // remove previous block
          d3.select('#legend').selectAll('g').remove();

          var selectedOption = d3.select(this).property("value")
          /*
      in the if-else statement, for each metric need to pass in the dataset, domain values, create the legend, and create color scheme
      */

     // attacks
          if (selectedOption=="count_attacks"){
            domain_values = [10, 100, 1000, 5000, 10000, 15000, 30000] 
            const legend_values = ['10', '100', '1000', '5000', '10K', '15K', '30K']
            color_scheme = d3.schemeReds[domain_values.length]
            legendBar = legend({
                  color: d3.scaleThreshold(
                      legend_values,
                      color_scheme
                  ),
                  title: "Number of Attacks",
                  tickSize: 0
              });
            csv_file = "https://raw.githubusercontent.com/grantgambetta/ECS272-Final-Project/main/src/assets/data/map/choropleth_attacks.csv"
          }
          // deaths
          else if (selectedOption=="kills"){
            domain_values = [20, 100, 1000, 5000, 15000, 30000, 45000]
            const legend_values = ['20', '100', '1000', '5000', '15K', '30K', '45K']
            color_scheme = d3.schemeReds[domain_values.length]
            legendBar = legend({
                  color: d3.scaleThreshold(
                      legend_values,
                      color_scheme
                  ),
                  title: "Number of Casualities",
                  tickSize: 0,
              });
            csv_file = "https://raw.githubusercontent.com/grantgambetta/ECS272-Final-Project/main/src/assets/data/map/choropleth_deaths.csv"
          }
          // injuries
          else {
              domain_values = [30, 100, 1000, 5000, 10000, 15000, 30000, 50000, 150000]
              const legend_values = ['30', '100', '1000', '5000', '10K', '15K', '30K', '50K', '150K']
              color_scheme = d3.schemeReds[domain_values.length]
              legendBar = legend({
                    color: d3.scaleThreshold(
                        legend_values,
                        color_scheme
                    ),
                    title: "Number of Injuries",
                    tickSize: 0
                });
              csv_file = "https://raw.githubusercontent.com/grantgambetta/ECS272-Final-Project/main/src/assets/data/map/choropleth_injured.csv"
          }
          // draw map again
          drawMap(csv_file) 
          
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
                        .attr("id","legendMap")
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

        // // dummy rectangles to select regions
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