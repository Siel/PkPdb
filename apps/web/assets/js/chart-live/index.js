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
        pointBorderColor: "#2c8f73",
        borderColor: "rgba(81, 197, 164, 0.5)",
        backgroundColor: "rgba(81, 197, 164, 0.05)",
      };
    });

    const options = {
      responsive: true,
      maintainAspectRatio: false,
      tooltips: {
        callbacks: {
          label: function (tooltipItem) {
            return tooltipItem.yLabel;
          },
        },
      },
      legend: {
        display: false,
      },
      scales: {
        yAxes: [
          {
            ticks: {
              fontColor: "black",
            },
            scaleLabel: {
              display: true,
              fontColor: "black",
              labelString: "Concentration [mg/L]",
            },
          },
        ],
        xAxes: [
          {
            type: "linear",
            ticks: {
              fontColor: "black",
              stepSize: 1,
              beginAtZero: true,
            },
            scaleLabel: {
              display: true,
              fontColor: "black",
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
  updated() {
    console.log("updated");
    // this.mounted();
  },
};

export default DatasetChart;
