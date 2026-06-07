function initOperatingHours() {
  const copyBtns = document.querySelectorAll(".hours-row__copy");

  if (copyBtns.length === 0) return;

  copyBtns.forEach((btn) => {
    // Reveal the button (Progressive Enhancement)
    btn.style.display = "inline-block";

    btn.addEventListener("click", function (e) {
      const sourceRow = this.closest(".hours-row");
      const sourceActive = sourceRow.querySelector(".hours-toggle").checked;
      const sourceOpen = sourceRow.querySelector(
        'input[type="time"][name$="_open"]',
      ).value;
      const sourceClose = sourceRow.querySelector(
        'input[type="time"][name$="_close"]',
      ).value;

      document.querySelectorAll(".hours-row").forEach((row) => {
        if (row !== sourceRow) {
          const toggle = row.querySelector(".hours-toggle");
          toggle.checked = sourceActive;

          row.querySelector('input[type="time"][name$="_open"]').value =
            sourceOpen;
          row.querySelector('input[type="time"][name$="_close"]').value =
            sourceClose;
        }
      });

      // Visual feedback
      const originalText = this.innerText;
      this.innerText = "Copied ✓";
      this.style.color = "var(--color-success)";

      setTimeout(() => {
        this.innerText = originalText;
        this.style.color = "";
      }, 1500);
    });
  });
}

function initStoreMap() {
  const mapContainer = document.getElementById("map");
  const geoControls = document.querySelector(".geo-controls");
  const latInput = document.getElementById("id_latitude");
  const lonInput = document.getElementById("id_longitude");
  const addressInput = document.getElementById("id_street_address");
  const locateBtn = document.getElementById("locate-btn");

  if (!mapContainer || !latInput || !lonInput) return;

  // Reveal the elements (Progressive Enhancement)
  mapContainer.style.display = "block";
  if (geoControls) geoControls.style.display = "flex";

  // Initialise the map (Default center to KL/Subang Jaya if inputs are empty)
  let initialLat = parseFloat(latInput.value) || 3.0738;
  let initialLon = parseFloat(lonInput.value) || 101.5183;

  const map = L.map("map").setView([initialLat, initialLon], 13);

  // Load OpenStreetMap tiles
  L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
    maxZoom: 19,
    attribution: "© OpenStreetMap",
    referrerPolicy: "strict-origin-when-cross-origin",
  }).addTo(map);

  // Create a Draggable Marker
  let marker = L.marker([initialLat, initialLon], { draggable: true }).addTo(
    map,
  );

  function updateInputs(lat, lon) {
    latInput.value = lat.toFixed(6);
    lonInput.value = lon.toFixed(6);
  }

  async function fetchAddress(lat, lon) {
    if (!addressInput) return;

    // Show a loading state so the user knows it's working
    addressInput.value = "Fetching address...";
    addressInput.disabled = true;

    const url = `https://nominatim.openstreetmap.org/reverse?format=json&lat=${lat}&lon=${lon}`;

    try {
      const response = await fetch(url);
      const data = await response.json();

      if (data && data.display_name) {
        addressInput.value = data.display_name;
      } else {
        addressInput.value = "Address not found for this location.";
      }
    } catch (error) {
      console.error("Geocoding failed:", error);
      addressInput.value = "Error fetching address. Please type it manually.";
    } finally {
      addressInput.disabled = false;
    }
  }

  // Map Event Listeners
  marker.on("dragend", function (e) {
    const position = marker.getLatLng();
    updateInputs(position.lat, position.lng);
    fetchAddress(position.lat, position.lng);
  });

  marker.on("drag", function (e) {
    const position = marker.getLatLng();
    updateInputs(position.lat, position.lng);
  });

  map.on("click", function (e) {
    marker.setLatLng(e.latlng);
    updateInputs(e.latlng.lat, e.latlng.lng);
    fetchAddress(e.latlng.lat, e.latlng.lng);
  });

  // When user manually types in the input fields, move the marker
  [latInput, lonInput].forEach((input) => {
    input.addEventListener("input", function () {
      let lat = parseFloat(latInput.value);
      let lon = parseFloat(lonInput.value);
      if (!isNaN(lat) && !isNaN(lon)) {
        let newLatLng = new L.LatLng(lat, lon);
        marker.setLatLng(newLatLng);
        map.panTo(newLatLng);
      }
    });
  });

  // HTML5 Geolocation (Get User's Current Location)
  if (locateBtn) {
    locateBtn.addEventListener("click", function () {
      if ("geolocation" in navigator) {
        locateBtn.innerText = "Locating...";
        navigator.geolocation.getCurrentPosition(
          function (position) {
            const lat = position.coords.latitude;
            const lon = position.coords.longitude;

            // Move map and marker
            map.setView([lat, lon], 16);
            marker.setLatLng([lat, lon]);
            updateInputs(lat, lon);
            fetchAddress(lat, lon);

            locateBtn.innerText = "📍 Get My Location";
          },
          function (error) {
            alert(
              "Unable to retrieve your location. You can type it manually.",
            );
            locateBtn.innerText = "📍 Get My Location";
          },
        );
      } else {
        alert("Geolocation is not supported by your browser.");
      }
    });
  }
}
