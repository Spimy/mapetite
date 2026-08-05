function initMerchantDashboard() {
  const revenueCanvas = document.getElementById("revenueChart");
  const hoursCanvas = document.getElementById("hoursChart");
  const itemsCanvas = document.getElementById("itemsChart");

  if (
    !revenueCanvas ||
    !hoursCanvas ||
    !itemsCanvas ||
    typeof Chart === "undefined"
  ) {
    return;
  }

  const sharedGridColor = "rgba(15, 23, 42, 0.08)";
  const sharedTextColor = "#475569";

  new Chart(revenueCanvas, {
    type: "line",
    data: {
      labels: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"],
      datasets: [
        {
          label: "Revenue",
          data: [1480, 1560, 1720, 1690, 1890, 2140, 1820],
          borderColor: "#0f766e",
          backgroundColor: "rgba(15, 118, 110, 0.12)",
          tension: 0.38,
          fill: true,
          pointRadius: 4,
          pointHoverRadius: 6,
        },
        {
          label: "Orders",
          data: [92, 95, 108, 101, 116, 132, 109],
          borderColor: "#f59e0b",
          backgroundColor: "rgba(245, 158, 11, 0.12)",
          tension: 0.38,
          fill: false,
          pointRadius: 3,
          borderDash: [6, 4],
        },
      ],
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: {
          labels: {
            color: sharedTextColor,
            usePointStyle: true,
          },
        },
        tooltip: {
          mode: "index",
          intersect: false,
        },
      },
      scales: {
        x: {
          ticks: { color: sharedTextColor },
          grid: { color: sharedGridColor },
        },
        y: {
          ticks: { color: sharedTextColor },
          grid: { color: sharedGridColor },
          beginAtZero: true,
        },
      },
    },
  });

  new Chart(hoursCanvas, {
    type: "bar",
    data: {
      labels: ["8", "10", "12", "14", "16", "18", "20", "22"],
      datasets: [
        {
          label: "Orders per hour",
          data: [8, 14, 34, 29, 21, 37, 41, 17],
          borderRadius: 8,
          backgroundColor: [
            "rgba(14, 165, 233, 0.4)",
            "rgba(14, 165, 233, 0.4)",
            "rgba(14, 165, 233, 0.55)",
            "rgba(14, 165, 233, 0.5)",
            "rgba(14, 165, 233, 0.45)",
            "rgba(14, 165, 233, 0.6)",
            "rgba(14, 165, 233, 0.7)",
            "rgba(14, 165, 233, 0.35)",
          ],
        },
      ],
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: { display: false },
      },
      scales: {
        x: {
          ticks: { color: sharedTextColor },
          grid: { display: false },
        },
        y: {
          ticks: { color: sharedTextColor },
          grid: { color: sharedGridColor },
          beginAtZero: true,
        },
      },
    },
  });

  new Chart(itemsCanvas, {
    type: "doughnut",
    data: {
      labels: [
        "Chicken Herb",
        "Shoyu Salmon",
        "Soy Glazed Tofu",
        "Brown Rice",
        "Salad",
      ],
      datasets: [
        {
          data: [31, 22, 19, 16, 12],
          backgroundColor: [
            "#0f766e",
            "#0891b2",
            "#f59e0b",
            "#22c55e",
            "#ef4444",
          ],
          borderWidth: 0,
        },
      ],
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      cutout: "62%",
      plugins: {
        legend: {
          position: "bottom",
          labels: {
            color: sharedTextColor,
            usePointStyle: true,
            boxWidth: 10,
          },
        },
      },
    },
  });
}
