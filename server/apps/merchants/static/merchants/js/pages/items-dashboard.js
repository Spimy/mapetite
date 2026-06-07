let updateTabIndicatorShared = null;

function initTabSwitch() {
  const SELECTORS = ".items-tabs__tab, .pagination a";
  const tabsContainer = document.querySelector(".items-tabs");
  let indicator = null;

  if (tabsContainer) {
    tabsContainer.classList.add("js-enhanced");

    indicator = document.createElement("div");
    indicator.className = "items-tabs__indicator";
    tabsContainer.appendChild(indicator);

    const initialActiveTab = tabsContainer.querySelector(
      '[aria-current="page"]',
    );
    updateIndicator(initialActiveTab, true);

    if (document.fonts) {
      document.fonts.ready.then(() => {
        const active = tabsContainer.querySelector('[aria-current="page"]');
        updateIndicator(active, true);
      });
    } else {
      window.addEventListener("load", () => {
        const active = tabsContainer.querySelector('[aria-current="page"]');
        updateIndicator(active, true);
      });
    }
  }

  function updateIndicator(activeTab, isInstant = false) {
    if (!activeTab || !indicator || !tabsContainer) return;

    const containerRect = tabsContainer.getBoundingClientRect();
    const tabRect = activeTab.getBoundingClientRect();

    const targetLeft =
      tabRect.left - containerRect.left + tabsContainer.scrollLeft;
    const targetWidth = tabRect.width;

    if (isInstant) {
      indicator.style.transform = `translateX(${targetLeft}px)`;
      indicator.style.width = `${targetWidth}px`;
      indicator.dataset.left = targetLeft;
      indicator.dataset.width = targetWidth;
      return;
    }

    const currentLeft = parseFloat(indicator.dataset.left) || 0;
    const currentWidth = parseFloat(indicator.dataset.width) || 0;

    const minLeft = Math.min(currentLeft, targetLeft);
    const maxRight = Math.max(
      currentLeft + currentWidth,
      targetLeft + targetWidth,
    );
    const stretchedWidth = maxRight - minLeft;

    indicator.animate(
      [
        {
          transform: `translateX(${currentLeft}px)`,
          width: `${currentWidth}px`,
        },
        {
          transform: `translateX(${minLeft}px)`,
          width: `${stretchedWidth}px`,
          offset: 0.4,
        },
        { transform: `translateX(${targetLeft}px)`, width: `${targetWidth}px` },
      ],
      {
        duration: 350,
        easing: "cubic-bezier(0.4, 0, 0.2, 1)",
        fill: "forwards",
      },
    );

    indicator.dataset.left = targetLeft;
    indicator.dataset.width = targetWidth;
  }

  // Expose this function globally to the search feature context
  updateTabIndicatorShared = updateIndicator;

  window.addEventListener("resize", () => {
    updateIndicator(
      document.querySelector('.items-tabs__tab[aria-current="page"]'),
      true,
    );
  });

  // Intercept Navigation (Tabs & Pagination)
  document.body.addEventListener("click", async (e) => {
    const link = e.target.closest(SELECTORS);
    if (!link) return;

    e.preventDefault();
    const url = link.href;

    if (link.classList.contains("items-tabs__tab")) {
      document
        .querySelectorAll(".items-tabs__tab")
        .forEach((t) => t.removeAttribute("aria-current"));
      link.setAttribute("aria-current", "page");
      updateIndicator(link);

      // Clear search parameters contextually if user physically changes category tabs
      const searchInput = document.querySelector(".items-page-header__search");
      if (searchInput) searchInput.value = "";
    }

    const listContainer = document.querySelector(".items-category__list");
    if (listContainer) {
      const skeletonCardHTML = `
            <li class="item-card is-skeleton">
              <div class="item-card__image-wrap"></div>
              <div class="item-card__content">
                <div class="skeleton-block skeleton-title"></div>
                <div class="skeleton-block skeleton-category"></div>
                <div class="skeleton-block skeleton-price"></div>
                <div class="item-card__actions">
                   <div class="skeleton-block skeleton-actions"></div>
                </div>
              </div>
            </li>
          `;
      listContainer.innerHTML = Array(6).fill(skeletonCardHTML).join("");
      document
        .querySelectorAll(".pagination a")
        .forEach((a) => (a.style.opacity = "0.5"));
    }

    try {
      const response = await fetch(url);
      if (!response.ok) throw new Error("Network response was not ok");

      const htmlString = await response.text();
      const doc = new DOMParser().parseFromString(htmlString, "text/html");

      const sectionsToUpdate = [".items-category", ".pagination-wrapper"];

      sectionsToUpdate.forEach((selector) => {
        const currentElement = document.querySelector(selector);
        const newElement = doc.querySelector(selector);
        if (currentElement && newElement) {
          currentElement.outerHTML = newElement.outerHTML;
        }
      });

      history.pushState(null, "", url);
    } catch (error) {
      console.error("Progressive enhancement failed:", error);
      window.location.href = url;
    }
  });

  window.addEventListener("popstate", () => {
    window.location.reload();
  });
}

function initSearch() {
  const searchForm = document.getElementById("search-form");
  const searchInput = searchForm?.querySelector('input[type="search"]');
  if (!searchForm || !searchInput) return;

  let debounceTimer;

  searchInput.addEventListener("input", (e) => {
    clearTimeout(debounceTimer);
    debounceTimer = setTimeout(() => {
      triggerSearchFetch();
    }, 400);
  });

  searchForm.addEventListener("submit", (e) => {
    e.preventDefault();
    clearTimeout(debounceTimer);
    triggerSearchFetch();
  });

  document.body.addEventListener("submit", async (e) => {
    const jumpForm = e.target.closest(".pagination__jump");
    if (!jumpForm) return;

    e.preventDefault();

    const url = new URL(window.location.href);
    const formData = new FormData(jumpForm);
    url.search = new URLSearchParams(formData).toString();
    const targetUrl = url.toString();

    const listContainer = document.querySelector(".items-category__list");
    if (listContainer) {
      const skeletonCardHTML = `
            <li class="item-card is-skeleton">
              <div class="item-card__image-wrap"></div>
              <div class="item-card__content">
                <div class="skeleton-block skeleton-title"></div>
                <div class="skeleton-block skeleton-category"></div>
                <div class="skeleton-block skeleton-price"></div>
                <div class="item-card__actions"><div class="skeleton-block skeleton-actions"></div></div>
              </div>
            </li>
          `;
      listContainer.innerHTML = Array(6).fill(skeletonCardHTML).join("");
      document
        .querySelectorAll(".pagination a, .pagination__jump-input")
        .forEach((el) => (el.style.opacity = "0.5"));
    }

    try {
      const response = await fetch(targetUrl);
      if (!response.ok) throw new Error("Network response was not ok");

      const htmlString = await response.text();
      const doc = new DOMParser().parseFromString(htmlString, "text/html");

      const sectionsToUpdate = [".items-category", ".pagination-wrapper"];

      sectionsToUpdate.forEach((selector) => {
        const currentElement = document.querySelector(selector);
        const newElement = doc.querySelector(selector);
        if (currentElement && newElement) {
          currentElement.outerHTML = newElement.outerHTML;
        }
      });

      history.pushState(null, "", targetUrl);
    } catch (error) {
      console.error("Jump to page failed:", error);
      window.location.href = targetUrl;
    }
  });

  async function triggerSearchFetch() {
    const url = new URL(window.location.href);
    const formData = new FormData(searchForm);

    // Global Search Logic: Set search, delete category and page
    url.searchParams.set("search", formData.get("search"));
    url.searchParams.delete("category");
    url.searchParams.delete("page");

    const targetUrl = url.toString();

    // Force the highlights back to "All Items" tab
    const tabs = document.querySelectorAll(".items-tabs__tab");
    if (tabs.length > 0) {
      tabs.forEach((t) => t.removeAttribute("aria-current"));
      const allItemsTab = tabs[0]; // First element is always the 'All Items' anchor
      allItemsTab.setAttribute("aria-current", "page");

      // Fire the shared animation function to slide the tab line safely over to All Items
      if (typeof updateTabIndicatorShared === "function") {
        updateTabIndicatorShared(allItemsTab);
      }
    }

    const listContainer = document.querySelector(".items-category__list");
    if (listContainer) {
      const skeletonCardHTML = `
            <li class="item-card is-skeleton">
              <div class="item-card__image-wrap"></div>
              <div class="item-card__content">
                <div class="skeleton-block skeleton-title"></div>
                <div class="skeleton-block skeleton-category"></div>
                <div class="skeleton-block skeleton-price"></div>
                <div class="item-card__actions"><div class="skeleton-block skeleton-actions"></div></div>
              </div>
            </li>
          `;
      listContainer.innerHTML = Array(6).fill(skeletonCardHTML).join("");
      document
        .querySelectorAll(".pagination-wrapper")
        .forEach((el) => (el.style.opacity = "0.5"));
    }

    try {
      const response = await fetch(targetUrl);
      if (!response.ok) throw new Error("Network response was not ok");

      const htmlString = await response.text();
      const doc = new DOMParser().parseFromString(htmlString, "text/html");

      const sectionsToUpdate = [".items-category", ".pagination-wrapper"];
      sectionsToUpdate.forEach((selector) => {
        const currentElement = document.querySelector(selector);
        const newElement = doc.querySelector(selector);
        if (currentElement && newElement) {
          currentElement.outerHTML = newElement.outerHTML;
        }
      });

      history.pushState(null, "", targetUrl);
    } catch (error) {
      console.error("Search enhancement failed:", error);
      window.location.href = targetUrl;
    }
  }
}

function initImageUpload() {
  const dropzones = document.querySelectorAll(
    ".items-form-group__file-dropzone",
  );

  dropzones.forEach((dropzone) => {
    dropzone.classList.add("js-enhanced");

    const fileInput = dropzone.querySelector('input[type="file"]');
    const placeholder = dropzone.querySelector(".file-dropzone-placeholder");
    const previewImage = dropzone.querySelector(".file-dropzone-preview");

    fileInput.addEventListener("change", (event) => {
      const file = event.target.files[0];

      if (file && file.type.startsWith("image/")) {
        const reader = new FileReader();

        reader.onload = (e) => {
          placeholder.style.display = "none";
          previewImage.src = e.target.result;
          previewImage.style.display = "block";
          dropzone.classList.add("items-form-group__file-dropzone--has-file");
        };

        reader.readAsDataURL(file);
      } else {
        previewImage.src = "";
        previewImage.style.display = "none";
        placeholder.style.display = "flex";
        dropzone.classList.remove("items-form-group__file-dropzone--has-file");
      }
    });
  });
}

function initItemToggles() {
  document.body.addEventListener("submit", async (e) => {
    const toggleForm = e.target.closest(".item-card__toggle-form");
    if (!toggleForm) return;

    e.preventDefault();

    const card = toggleForm.closest(".item-card");
    const iconOn = toggleForm.querySelector(".item-card__toggle-icon-on");
    const iconOff = toggleForm.querySelector(".item-card__toggle-icon-off");
    const imageWrap = card.querySelector(".item-card__image-wrap");

    // Toggle the grey-out class
    card.classList.toggle("item-card--hidden");

    // Swap the icons based on the new state
    const isNowHidden = card.classList.contains("item-card--hidden");
    if (isNowHidden) {
      iconOn.hidden = true;
      iconOff.hidden = false;

      // Inject the "Hidden" badge instantly if it doesn't exist
      if (!card.querySelector(".item-card__status-badge")) {
        imageWrap.insertAdjacentHTML(
          "afterbegin",
          '<span class="item-card__status-badge">Hidden</span>',
        );
      }
    } else {
      iconOn.hidden = false;
      iconOff.hidden = true;

      // Remove the "Hidden" badge
      const badge = card.querySelector(".item-card__status-badge");
      if (badge) badge.remove();
    }

    try {
      const formData = new FormData(toggleForm);

      // Grab the current store ID from the hidden input in your "Add Item" popover
      // to satisfy the View's security check
      const currentStoreId = document.querySelector(
        'input[name="current_store"]',
      )?.value;
      if (currentStoreId) formData.append("current_store", currentStoreId);

      const response = await fetch(toggleForm.action, {
        method: "POST",
        body: formData,
        headers: {
          "X-Requested-With": "XMLHttpRequest",
        },
      });

      if (!response.ok) throw new Error("Failed to toggle item state.");
    } catch (error) {
      console.error("Toggle failed, reverting UI:", error);
      // If the server crashes or the network drops, reload the page to snap the UI back to the actual state from the server
      window.location.reload();
    }
  });
}

function initItemEditing() {
  document.body.addEventListener("click", (e) => {
    const editBtn = e.target.closest(".js-edit-item-btn");
    if (!editBtn) return;

    e.preventDefault();

    const editForm = document.getElementById("edit-item-form");
    const popover = document.getElementById("edit-item-popover");

    if (!editForm || !popover) {
      window.location.href = editBtn.href;
      return;
    }

    editForm.action = editBtn.dataset.url;

    const safeQuery = (selector) => editForm.querySelector(selector);

    if (safeQuery("#edit-item-id"))
      safeQuery("#edit-item-id").value = editBtn.dataset.id;
    if (safeQuery('[name="name"]'))
      safeQuery('[name="name"]').value = editBtn.dataset.name;
    if (safeQuery('[name="price"]'))
      safeQuery('[name="price"]').value = editBtn.dataset.price;
    if (safeQuery('[name="category"]'))
      safeQuery('[name="category"]').value = editBtn.dataset.category;
    if (safeQuery('[name="description"]'))
      safeQuery('[name="description"]').value = editBtn.dataset.description;
    if (safeQuery('[name="calories"]'))
      safeQuery('[name="calories"]').value = editBtn.dataset.calories;
    if (safeQuery('[name="stock_status"]'))
      safeQuery('[name="stock_status"]').value = editBtn.dataset.stockStatus;

    // Hydrate ALL checkboxes (Dietary, Sustainability, Visibility)
    const checkboxes = [
      { name: "is_active", dataKey: "isActive" },
      { name: "organic", dataKey: "organic" },
      { name: "vegetarian", dataKey: "vegetarian" },
      { name: "gluten_free", dataKey: "glutenFree" },
      { name: "dairy_free", dataKey: "dairyFree" },
      { name: "contains_nuts", dataKey: "containsNuts" },
      { name: "eco_packaging", dataKey: "ecoPackaging" },
      { name: "locally_sourced", dataKey: "locallySourced" },
    ];

    checkboxes.forEach((box) => {
      const checkboxEl = safeQuery(`[name="${box.name}"]`);
      if (checkboxEl && editBtn.dataset[box.dataKey] !== undefined) {
        checkboxEl.checked = editBtn.dataset[box.dataKey] === "true";
      }
    });

    const dropzone = editForm.querySelector(".items-form-group__file-dropzone");
    if (dropzone) {
      const preview = dropzone.querySelector(".file-dropzone-preview");
      const placeholder = dropzone.querySelector(".file-dropzone-placeholder");
      const imageUrl = editBtn.dataset.imageUrl;

      if (imageUrl) {
        preview.src = imageUrl;
        preview.hidden = false;
        preview.style.display = "block";
        placeholder.style.display = "none";
        dropzone.classList.add("items-form-group__file-dropzone--has-file");
      } else {
        preview.src = "";
        preview.hidden = true;
        preview.style.display = "none";
        placeholder.style.display = "flex";
        dropzone.classList.remove("items-form-group__file-dropzone--has-file");
      }
    }

    popover.showPopover();
  });
}
