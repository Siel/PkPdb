import Chart from "chart.js";

const DatasetChart = {
  mounted() {
    const datasets = Array.from(this.el.children || []).map((val) => {
      let label = val.dataset.label;
      let data = Array.from(val.children || []).map(({ dataset: { x, y } }) => {
        return { x: parseFloat(x), y: parseFloat(y) };
      });
      return {
        label,
        data,
        borderWidth: 1,
        pointBorderColor: "red",
        borderColor: "red",
        pointBackgroundColor: "red",
        backgroundColor: "red",
      };
    });

    const options = {
      responsive: true,
      maintainAspectRatio: false,
      legend: {
        labels: {
          fontColor: "white",
        },
      },
      scales: {
        yAxes: [
          {
            ticks: {
              fontColor: "white",
            },
            scaleLabel: {
              display: true,
              fontColor: "white",
              labelString: "Concentration [mg/L]",
            },
          },
        ],
        xAxes: [
          {
            type: "linear",
            ticks: {
              fontColor: "white",
              stepSize: 1,
              beginAtZero: true,
            },
            scaleLabel: {
              display: true,
              fontColor: "white",
              labelString: "Time [h]",
            },
          },
        ],
      },
    };

    console.log(datasets);
    var ctx = document.getElementById("dataset-chart");
    console.log(this.el);
    var myChart = new Chart(ctx, {
      type: "line",
      data: {
        label: "epa",
        datasets: datasets,
      },
      options: options,
    });
  },
};

export default DatasetChart;
