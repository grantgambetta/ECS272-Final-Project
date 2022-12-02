<template>
    <div id="stackedArea" style = "position: absolute; left: 1050px;"></div>
</template>

<script>
    import * as d3 from "d3";
    // import dataStackedArea from "../../assets/data/stackedArea.json"; /* Example of reading in data direct from file*/
    import dataStackedArea from "../../assets/data/timeSeries/world_count_attacks.json"; /* Example of reading in data direct from file*/

    export default {
        name: 'StackedArea',
        data() {
            return {
                /*name: 'Hello',
                someLocalValues: [1, 2, 3, 4, 5],*/

            }
        },
        props:{
            myStackedAreaData: {
                type: Object,
                },
            regionString:{
                type: String,
                },
            metricString:{
                type: String,
                }
        },
        watch:{
            myStackedAreaData: function(newVal, oldVal) { // watch event
            // immediate: true,
            // console.log('Prop changed: ', newVal, ' | was: ', oldVal)
            d3.select("#stackedArea").selectAll('svg').remove(); // remove previous block
            this.drawStackedArea(newVal, "#stackedArea",this.regionString)
            }
        },
        mounted(){
            console.log(dataStackedArea);
            // let localData = d3.csv(dataStackedArea);
            let localData = dataStackedArea['data'];
            this.drawStackedArea(localData, "#stackedArea",this.regionString) /* Example of reading data from a json file */
            console.log("Data Passed down as a Prop  ", this.myStackedAreaData)
        },
        methods: {
            drawStackedArea(data, id,region_selected) {
                
                // Source: https://d3-graph-gallery.com/graph/stackedarea_template.html
                // set the dimensions and margins of the graph
                const margin = {top: 60, right: 160, bottom: 50, left: 80},
                    width = 950 - margin.left - margin.right,
                    height = 450 - margin.top - margin.bottom;

                // const margin = { top: 40, right: 160, bottom: 40, left: 80};
                // const height = 300;
                // const width = 620; 

                // append the svg object to the body of the page
                const svg = d3.select(id).append("svg")
                    .attr("width", width + margin.left + margin.right)
                    .attr("height", height + margin.top + margin.bottom)
                .append("g")
                    .attr("transform",
                        `translate(${margin.left}, ${margin.top})`);

                //////////
                // GENERAL //
                //////////

                // Colors Legend
                // color generator: https://observablehq.com/@d3/color-schemes 
                // (can modify the code to generate 24 discrete categories)

                var keys=[]
                switch(region_selected){
                case "world":
                    keys=["Middle East & North Africa","South Asia","South America","Sub-Saharan Africa",
                                "Western Europe","Southeast Asia","Central America & Caribbean","Eastern Europe",
                                "North America","East Asia","Central Asia","Australasia & Oceania"];
                    break;
                case "CentralAmericaCaribbean":
                    keys=["El Salvador","Guatemala","Nicaragua","Honduras","Haiti",
                            "Panama","Dominican Republic","Costa Rica","Guadeloupe","Jamaica",
                            "Cuba","Other"];
                    break;
                case "NorthAmerica":
                    keys=["United States","Mexico","Canada"]; // 3 only
                    break;
                case "SoutheastAsia":
                    keys=["Philippines","Thailand","Indonesia","Myanmar","Cambodia",
                            "Malaysia","Laos","Vietnam","East Timor","Singapore",
                            "Brunei","Other"];
                    break;
                case "WesternEurope":
                    keys=["United Kingdom","Spain","France","Italy","Greece",
                            "Germany","West Germany (FRG)","Ireland","Belgium","Portugal",
                            "Cyprus","Other"];
                    break;
                case "EastAsia":
                    keys=["Japan","China","Taiwan","South Korea","Macau",
                            "Hong Kong","North Korea"]; // 7 only
                    break;
                case "SouthAmerica":
                    keys=["Colombia","Peru","Chile","Argentina","Bolivia",
                                "Venezuela","Brazil","Ecuador","Paraguay","Uruguay",
                                "Suriname","Other"];
                    break;
                case "EasternEurope":
                    keys=["Russia","Ukraine","Yugoslavia","Kosovo","Bosnia-Herzegovina",
                            "Macedonia","Albania","Soviet Union","Croatia","Bulgaria",
                            "Hungary","Other"];
                    break;
                case "Sub-SaharanAfrica":
                    keys=["Somalia","Nigeria","South Africa","Sudan","Democratic Republic of the Congo",
                            "Kenya","Burundi","Mali","Angola","Uganda",
                            "Mozambique","Other"];
                    break;
                case "MiddleEastNorthAfrica":
                    keys=["Iraq","Turkey","Yemen","Algeria",
                            "Egypt","Lebanon","Libya","West Bank and Gaza Strip",
                            "Syria","Israel","Iran","Other"];
                    break;
                case "AustralasiaOceania":
                    keys=["Australia","Papua New Guinea","New Caledonia","New Zealand","Fiji",
                            "Solomon Islands","French Polynesia","Vanuatu","New Hebrides","Wallis and Futuna"]; //10 only
                    break;
                case "SouthAsia":
                    keys=["Pakistan","Afghanistan","India","Sri Lanka","Bangladesh",
                            "Nepal","Maldives","Bhutan","Mauritius"]; //9 only
                    break;
                case "CentralAsia":
                    keys=["Georgia","Tajikistan","Azerbaijan","Kyrgyzstan","Kazakhstan",
                            "Armenia","Uzbekistan","Turkmenistan"]; // 8 only
                    break;
                }

                var color_countries=["#fcb59b","#fca082","#fc8a6b","#fb7455",
                                    "#f75d43","#ef4533","#e23028","#d01f20",
                                    "#bb151a","#a40f16","#870811","#67000d"].reverse()  // scale of red
                color_countries=color_countries.slice(0,keys.length)

                // const keys =["Middle East & North Africa","South Asia","South America","Sub-Saharan Africa",
                // "Western Europe","Southeast Asia","Central America & Caribbean","Eastern Europe",
                // "North America","East Asia","Central Asia","Australasia & Oceania"]
            
                const color = d3.scaleOrdinal()
                    .domain(keys)
                    .range(["#e6ab02","#1b9e77","#d95f02","#66a61e",
                            "#e7298a","#666666","#a6761d","#7570b3",
                            "#33a02c","#fdbf6f","#1f78b4","#000000"]); 


                //stack the data?
                const stackedData = d3.stack()
                    .keys(keys)
                    (data)

                //////////
                // AXIS //
                //////////

                // Add X axis
                var format_date = d3.timeParse("%Y-%m-%d")
                const x = d3.scaleTime()
                    .domain(d3.extent(data, function(d) { return format_date(d.yearDate); }))
                    .range([ 0, width ]);
                
                const xAxis = svg.append("g")
                    .attr("transform", `translate(0, ${height})`)
                    .call(d3.axisBottom(x).ticks(5))
                    .style("font", "14px arial");

                // Add X axis label:
                // svg.append("text")
                //     .attr("text-anchor", "end")
                //     .attr("x", width - 330)
                //     .attr("y", height+45)
                //     .text("Year")
                //     .style("font-size","18px");


                var metricText=d3.select('#metric').property('value')
                switch (metricText){
                case "count_attacks":
                    metricText="Number of Attacks"
                    break;
                case "kills":
                    metricText="Total People Killed"
                    break;
                case "wounded":
                    metricText="Total People Injured"
                    break;
                }

                // Add Y axis label:
                svg.append("text")
                    .attr("text-anchor", "end")
                    .attr("x", -40)
                    .attr("y", -15 )
                    .text(metricText)
                    .attr("text-anchor", "start")
                    .style("font-size", "16px")

                // Add Y axis
                
                // get maximum value in whole data set
                var dataNumeric=data;
                // remove year column not numeric
                dataNumeric = dataNumeric.map(({yearDate, ...rest}) => {
                    return rest;
                    }); 
                // get max Year as the sum
                var maxValue=0
                for (var i = 0; i < dataNumeric.length; i++){
                    var obj = dataNumeric[i];
                    let cumSum=0
                    for (var key in obj){
                        cumSum+=obj[key];
                    }
                    maxValue=Math.max(cumSum,maxValue); // update max year
                }

                const y = d3.scaleLinear()
                    .domain([0, maxValue*1.2]) // scale a little larger
                    .range([ height, 0 ]);
                svg.append("g")
                    .call(d3.axisLeft(y).ticks(5))
                    .style("font", "14px arial");

                //////////
                // BRUSHING AND CHART //
                //////////

                // Add a clipPath: everything out of this area won't be drawn.
                const clip = svg.append("defs").append("svg:clipPath")
                    .attr("id", "clip")
                    .append("svg:rect")
                    .attr("width", width )
                    .attr("height", height )
                    .attr("x", 0)
                    .attr("y", 0);

                // Add brushing
                const brush = d3.brushX()                 // Add the brush feature using the d3.brush function
                    .extent( [ [0,0], [width,height] ] ) // initialise the brush area: start at 0,0 and finishes at width,height: it means I select the whole graph area
                    .on("end", updateChart) // Each time the brush selection changes, trigger the 'updateChart' function

                // Create the scatter variable: where both the circles and the brush take place
                const areaChart = svg.append('g')
                    .attr("clip-path", "url(#clip)")

                // Area generator
                const area = d3.area()
                    .x(function(d) { return x(format_date(d.data.yearDate)); })
                    .y0(function(d) { return y(d[0]); })
                    .y1(function(d) { return y(d[1]); })

                // Show the areas
                areaChart
                    .selectAll("mylayers")
                    .data(stackedData)
                    .join("path")
                    .attr("class", function(d) { return "myArea " + d.key.replaceAll(" ","-").replaceAll("/","-").replaceAll("&","-") }) // to handle spaces and / in the highlight action
                    .style("fill", function(d) { return color(d.key); })
                    .attr("d", area)

                // Add the brushing
                areaChart
                    .append("g")
                    .attr("class", "brush")
                    .call(brush);

                let idleTimeout
                function idled() { idleTimeout = null; }

                // A function that update the chart for given boundaries
                function updateChart(event,d) {

                    var extent = event.selection

                    // If no selection, back to initial coordinate. Otherwise, update X axis domain
                    if(!extent){
                    if (!idleTimeout) return idleTimeout = setTimeout(idled, 350); // This allows to wait a little bit
                    x.domain(d3.extent(data, function(d) { return format_date(d.yearDate); }))
                    }else{
                    x.domain([ x.invert(extent[0]), x.invert(extent[1]) ])
                    areaChart.select(".brush").call(brush.move, null) // This remove the grey brush area as soon as the selection has been done
                    }

                    // Update axis and area position
                    xAxis.transition().duration(1000).call(d3.axisBottom(x).ticks(5))
                    areaChart
                    .selectAll("path")
                    .transition().duration(1000)
                    .attr("d", area)
                    }



                    //////////
                    // HIGHLIGHT GROUP //
                    //////////

                    // What to do when one group is hovered
                    const highlight = function(event,d){
                    // reduce opacity of all groups
                    d3.selectAll(".myArea").style("opacity", .1)
                    // expect the one that is hovered
                    d3.select("."+d.replaceAll(" ","-").replaceAll("/","-").replaceAll("&","-")).style("opacity", 1)
                    }

                    // And when it is not hovered anymore
                    const noHighlight = function(event,d){
                    d3.selectAll(".myArea").style("opacity", 1)
                    }



                    //////////
                    // LEGEND //
                    //////////

                    // Add one dot in the legend for each name.
                    const size = 10
                    svg.selectAll("myrect")
                    .data(keys)
                    .join("rect")
                        .attr("x", 20)
                        .attr("y", function(d,i){ return 10 + i*(size+5)}) // 100 is where the first dot appears. 25 is the distance between dots
                        .attr("width", size)
                        .attr("height", size)
                        .style("fill", function(d){ return color(d)})
                        .on("mouseover", highlight)
                        .on("mouseleave", noHighlight)

                    // Add one dot in the legend for each name.
                    svg.selectAll("mylabels")
                    .data(keys)
                    .join("text")
                        .attr("x", 20 + size*1.2)
                        .attr("y", function(d,i){ return 10 + i*(size+5) + (size/2)}) // 100 is where the first dot appears. 25 is the distance between dots
                        .style("fill", function(d){ return color(d)})
                        .text(function(d){ return d})
                        .attr("text-anchor", "left")
                        .style("alignment-baseline", "middle")
                        .on("mouseover", highlight)
                        .on("mouseleave", noHighlight)


            },
        }
    }

</script>