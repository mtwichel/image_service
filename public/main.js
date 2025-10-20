// API Key management and HTMX integration
document.addEventListener('DOMContentLoaded', function () {
  // Load images table with API key
  function loadImagesTable() {
    const apiKey = sessionStorage.getItem('apiKey');
    const tableDiv = document.getElementById('images-table');

    if (!apiKey) {
      const key = prompt('Enter API Key:');
      if (key && key.trim()) {
        sessionStorage.setItem('apiKey', key);
        fetchImagesTable(key);
      } else {
        tableDiv.innerHTML = '<div class="text-center py-8 text-red-600">API Key required to load images</div>';
      }
    } else {
      fetchImagesTable(apiKey);
    }
  }

  // Fetch and display images table
  function fetchImagesTable(apiKey) {
    fetch('/dashboard/files', {
      headers: {
        'x-api-key': apiKey
      }
    })
      .then(response => {
        if (response.status === 401) {
          // Clear invalid API key and prompt for new one
          sessionStorage.removeItem('apiKey');
          const tableDiv = document.getElementById('images-table');
          tableDiv.innerHTML = '<div class="text-center py-8 text-red-600">Invalid API Key. Please try again.</div>';
          setTimeout(() => {
            loadImagesTable();
          }, 1500);
          return;
        }
        return response.text();
      })
      .then(html => {
        if (html) {
          document.getElementById('images-table').innerHTML = html;
          // Process HTMX attributes on the newly loaded content
          htmx.process(document.getElementById('images-table'));
        }
      })
      .catch(error => {
        document.getElementById('images-table').innerHTML = '<div class="text-center py-8 text-red-600">Failed to load images</div>';
      });
  }

  // Rate limiting for uploads
  let lastUploadTime = 0;
  const UPLOAD_COOLDOWN = 2000; // 2 seconds between uploads

  // Configure HTMX requests to include API key
  document.body.addEventListener('htmx:configRequest', function (evt) {
    const apiKey = sessionStorage.getItem('apiKey');
    if (apiKey) {
      evt.detail.headers['x-api-key'] = apiKey;
    }

    // Debug delete requests
    if (evt.detail.requestConfig && evt.detail.requestConfig.verb === 'delete') {
      console.log('Delete request initiated:', evt.detail.requestConfig.path);
      console.log('API Key being sent:', apiKey ? 'Present' : 'Missing');
    }

    // Rate limiting check for upload requests
    if (evt.detail.elt && evt.detail.elt.id === 'upload-form') {
      const now = Date.now();
      if (now - lastUploadTime < UPLOAD_COOLDOWN) {
        evt.preventDefault();
        const uploadResult = document.getElementById('upload-result');
        uploadResult.textContent = 'Please wait before uploading again.';
        uploadResult.className = 'mt-2 p-2 rounded text-sm [&:not(:empty)]:bg-yellow-100 [&:not(:empty)]:text-yellow-700 [&:not(:empty)]:border [&:not(:empty)]:border-yellow-300';
        setTimeout(() => {
          uploadResult.textContent = '';
          uploadResult.className = 'mt-2 p-2 rounded text-sm [&:not(:empty)]:bg-green-100 [&:not(:empty)]:text-green-700 [&:not(:empty)]:border [&:not(:empty)]:border-green-300';
        }, 2000);
        return;
      }
      lastUploadTime = now;
    }
  });

  // Handle upload progress
  document.body.addEventListener('htmx:xhr:progress', function (evt) {
    const progressBar = document.getElementById('progress');
    if (progressBar && evt.detail.loaded && evt.detail.total) {
      progressBar.value = (evt.detail.loaded / evt.detail.total) * 100;
    }
  });

  // Handle upload completion and delete responses
  document.body.addEventListener('htmx:afterRequest', function (evt) {
    // Handle delete requests
    if (evt.detail.requestConfig && evt.detail.requestConfig.verb === 'delete') {
      console.log('Delete request completed:', evt.detail.xhr.status);
      if (evt.detail.xhr.status === 401) {
        alert('Invalid API Key. Please refresh the page and enter a valid API key.');
        sessionStorage.removeItem('apiKey');
        location.reload();
      } else if (evt.detail.xhr.status === 404) {
        alert('File not found.');
      } else if (evt.detail.xhr.status >= 400) {
        alert('Failed to delete file. Please try again.');
      }
      // On success (200), HTMX will automatically remove the row due to empty response
      return;
    }

    // Handle upload form requests
    if (evt.detail.elt && evt.detail.elt.id === 'upload-form') {
      const uploadResult = document.getElementById('upload-result');
      const progressBar = document.getElementById('progress');

      if (evt.detail.xhr.status === 200 || evt.detail.xhr.status === 201) {
        uploadResult.textContent = 'Image uploaded successfully!';
        uploadResult.className = 'mt-2 p-2 rounded text-sm [&:not(:empty)]:bg-green-100 [&:not(:empty)]:text-green-700 [&:not(:empty)]:border [&:not(:empty)]:border-green-300';
        // Reset the form
        document.getElementById('upload-form').reset();
        // Reset progress bar
        if (progressBar) progressBar.value = 0;
        // Reset drop zone text
        updateDropZoneText(null);
        setTimeout(() => {
          uploadResult.textContent = '';
          uploadResult.className = 'mt-2 p-2 rounded text-sm [&:not(:empty)]:bg-green-100 [&:not(:empty)]:text-green-700 [&:not(:empty)]:border [&:not(:empty)]:border-green-300';
        }, 3000);
      } else if (evt.detail.xhr.status === 401) {
        uploadResult.textContent = 'Invalid API Key. Please change it and try again.';
        uploadResult.className = 'mt-2 p-2 rounded text-sm [&:not(:empty)]:bg-red-100 [&:not(:empty)]:text-red-700 [&:not(:empty)]:border [&:not(:empty)]:border-red-300';
        sessionStorage.removeItem('apiKey');
      } else if (evt.detail.xhr.status === 413) {
        uploadResult.textContent = 'File too large. Maximum size is 10MB.';
        uploadResult.className = 'mt-2 p-2 rounded text-sm [&:not(:empty)]:bg-red-100 [&:not(:empty)]:text-red-700 [&:not(:empty)]:border [&:not(:empty)]:border-red-300';
      } else if (evt.detail.xhr.status === 400) {
        const responseText = evt.detail.xhr.responseText;
        if (responseText.includes('Invalid file type')) {
          uploadResult.textContent = 'Invalid file type. Only images (JPEG, PNG, GIF, WebP) are allowed.';
        } else if (responseText.includes('No file provided')) {
          uploadResult.textContent = 'Please select a file to upload.';
        } else {
          uploadResult.textContent = 'Invalid file. Please check your file and try again.';
        }
        uploadResult.className = 'mt-2 p-2 rounded text-sm [&:not(:empty)]:bg-red-100 [&:not(:empty)]:text-red-700 [&:not(:empty)]:border [&:not(:empty)]:border-red-300';
      } else {
        uploadResult.textContent = 'Upload failed. Please try again.';
        uploadResult.className = 'mt-2 p-2 rounded text-sm [&:not(:empty)]:bg-red-100 [&:not(:empty)]:text-red-700 [&:not(:empty)]:border [&:not(:empty)]:border-red-300';
      }
    }
  });

  // Reset API key button
  function resetApiKey() {
    sessionStorage.removeItem('apiKey');
    document.getElementById('images-table').innerHTML = '<div class="text-center py-8">Loading images...</div>';
    loadImagesTable();
  }

  document.getElementById('reset-api-key').addEventListener('click', resetApiKey);

  // Keyboard shortcut: Ctrl+R or Cmd+R (in addition to browser refresh)
  document.addEventListener('keydown', function (e) {
    if ((e.ctrlKey || e.metaKey) && e.shiftKey && e.key === 'K') {
      e.preventDefault();
      resetApiKey();
    }
  });

  // Client-side file validation before upload
  function validateFileBeforeUpload() {
    const fileInput = document.getElementById('file-input');
    const uploadResult = document.getElementById('upload-result');

    if (!fileInput.files || !fileInput.files[0]) {
      return false;
    }

    const file = fileInput.files[0];
    const maxSize = 10 * 1024 * 1024; // 10MB
    const allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp'];

    // Check file size
    if (file.size > maxSize) {
      uploadResult.textContent = 'File too large. Maximum size is 10MB.';
      uploadResult.className = 'mt-2 p-2 rounded text-sm [&:not(:empty)]:bg-red-100 [&:not(:empty)]:text-red-700 [&:not(:empty)]:border [&:not(:empty)]:border-red-300';
      return false;
    }

    // Check file type
    if (!allowedTypes.includes(file.type)) {
      uploadResult.textContent = 'Invalid file type. Only images (JPEG, PNG, GIF, WebP) are allowed.';
      uploadResult.className = 'mt-2 p-2 rounded text-sm [&:not(:empty)]:bg-red-100 [&:not(:empty)]:text-red-700 [&:not(:empty)]:border [&:not(:empty)]:border-red-300';
      return false;
    }

    // Clear any previous error messages
    uploadResult.textContent = '';
    uploadResult.className = 'mt-2 p-2 rounded text-sm [&:not(:empty)]:bg-green-100 [&:not(:empty)]:text-green-700 [&:not(:empty)]:border [&:not(:empty)]:border-green-300';
    return true;
  }

  // Add file validation on form submit
  document.getElementById('upload-form').addEventListener('submit', function (e) {
    if (!validateFileBeforeUpload()) {
      e.preventDefault();
      return false;
    }
  });

  // Function to update drop zone text when file is selected
  function updateDropZoneText(fileName) {
    const dropZone = document.getElementById('drop-zone');
    const textElement = dropZone.querySelector('#drop-text');
    if (textElement) {
      if (fileName) {
        textElement.textContent = 'Selected: ' + fileName;
        textElement.className = 'text-sm text-blue-600 mb-1 font-medium';
      } else {
        textElement.textContent = 'Drag and drop your image here';
        textElement.className = 'text-sm text-gray-600 mb-1';
      }
    }
  }

  // Setup drag and drop functionality
  function setupDragAndDrop() {
    const dropZone = document.getElementById('drop-zone');
    const fileInput = document.getElementById('file-input');

    if (!dropZone || !fileInput) return;

    // Prevent default drag behaviors
    function preventDefaults(e) {
      e.preventDefault();
      e.stopPropagation();
    }

    ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
      dropZone.addEventListener(eventName, preventDefaults, false);
      document.body.addEventListener(eventName, preventDefaults, false);
    });

    // Highlight drop zone when item is dragged over it
    function highlight(e) {
      dropZone.classList.add('border-blue-500', 'bg-blue-50');
    }

    function unhighlight(e) {
      dropZone.classList.remove('border-blue-500', 'bg-blue-50');
    }

    ['dragenter', 'dragover'].forEach(eventName => {
      dropZone.addEventListener(eventName, highlight, false);
    });

    ['dragleave', 'drop'].forEach(eventName => {
      dropZone.addEventListener(eventName, unhighlight, false);
    });

    // Handle dropped files
    dropZone.addEventListener('drop', function (e) {
      const dt = e.dataTransfer;
      const files = dt.files;

      if (files.length > 0) {
        fileInput.files = files;
        updateDropZoneText(files[0].name);
        validateFileBeforeUpload();
      }
    }, false);

    // Add click handler for drop zone
    dropZone.addEventListener('click', function () {
      fileInput.click();
    });

    // Add file input change handler
    fileInput.addEventListener('change', function () {
      validateFileBeforeUpload();
      if (fileInput.files && fileInput.files[0]) {
        updateDropZoneText(fileInput.files[0].name);
      } else {
        updateDropZoneText(null);
      }
    });
  }

  // Make updateDropZoneText available globally for the upload completion handler
  window.updateDropZoneText = updateDropZoneText;

  // Initialize drag and drop
  setupDragAndDrop();

  // Process HTMX attributes when content is added to the table
  document.body.addEventListener('htmx:afterSwap', function (evt) {
    // If content was swapped into the table body, process HTMX attributes
    if (evt.detail.target && evt.detail.target.id === 'table-body') {
      htmx.process(evt.detail.target);
    }
  });



  // Image filtering functionality
  function setupImageFilter() {
    const filterInput = document.getElementById('image-filter');
    const clearButton = document.getElementById('clear-filter');
    if (!filterInput) return;

    filterInput.addEventListener('input', function () {
      const searchTerm = this.value.toLowerCase();
      filterImages(searchTerm);

      // Show/hide clear button
      if (clearButton) {
        if (searchTerm) {
          clearButton.classList.remove('hidden');
        } else {
          clearButton.classList.add('hidden');
        }
      }
    });

    // Clear button functionality
    if (clearButton) {
      clearButton.addEventListener('click', function () {
        filterInput.value = '';
        filterImages('');
        clearButton.classList.add('hidden');
        updateFilterStatus(0, 0, ''); // Clear status message
        filterInput.focus();
      });
    }
  }

  function filterImages(searchTerm) {
    const tableBody = document.getElementById('table-body');
    if (!tableBody) return;

    const rows = tableBody.querySelectorAll('tr');
    let visibleCount = 0;

    rows.forEach(row => {
      // Find the cell containing the original name (second cell in the row)
      const originalNameCell = row.cells[1];
      if (originalNameCell) {
        const originalName = originalNameCell.textContent.toLowerCase();
        const shouldShow = searchTerm === '' || originalName.includes(searchTerm);

        if (shouldShow) {
          row.style.display = '';
          visibleCount++;
        } else {
          row.style.display = 'none';
        }
      }
    });

    // Show a message if no images match the filter
    updateFilterStatus(visibleCount, rows.length, searchTerm);
  }

  function updateFilterStatus(visibleCount, totalCount, searchTerm) {
    let statusDiv = document.getElementById('filter-status');

    // Create status div if it doesn't exist
    if (!statusDiv) {
      statusDiv = document.createElement('div');
      statusDiv.id = 'filter-status';
      statusDiv.className = 'text-sm text-gray-600 mb-4 px-4';

      const imagesTable = document.getElementById('images-table');
      if (imagesTable && imagesTable.firstChild) {
        imagesTable.insertBefore(statusDiv, imagesTable.firstChild);
      }
    }

    if (searchTerm && visibleCount === 0 && totalCount > 0) {
      statusDiv.textContent = `No images found matching "${searchTerm}"`;
      statusDiv.className = 'text-sm text-gray-600 mb-4 px-4 py-2 bg-yellow-50 border border-yellow-200 rounded';
    } else if (searchTerm && visibleCount < totalCount) {
      statusDiv.textContent = `Showing ${visibleCount} of ${totalCount} images`;
      statusDiv.className = 'text-sm text-gray-600 mb-4 px-4';
    } else {
      statusDiv.textContent = '';
      statusDiv.className = 'text-sm text-gray-600 mb-4 px-4';
    }
  }

  // Setup filter when images table is loaded or updated
  function initializeFilter() {
    setupImageFilter();
    // Clear any existing filter when new content is loaded
    const filterInput = document.getElementById('image-filter');
    if (filterInput) {
      filterInput.value = '';
    }
  }

  // Setup filter after images are loaded
  const originalFetchImagesTable = fetchImagesTable;
  fetchImagesTable = function (apiKey) {
    fetch('/dashboard/files', {
      headers: {
        'x-api-key': apiKey
      }
    })
      .then(response => {
        if (response.status === 401) {
          // Clear invalid API key and prompt for new one
          sessionStorage.removeItem('apiKey');
          const tableDiv = document.getElementById('images-table');
          tableDiv.innerHTML = '<div class="text-center py-8 text-red-600">Invalid API Key. Please try again.</div>';
          setTimeout(() => {
            loadImagesTable();
          }, 1500);
          return;
        }
        return response.text();
      })
      .then(html => {
        if (html) {
          document.getElementById('images-table').innerHTML = html;
          // Process HTMX attributes on the newly loaded content
          htmx.process(document.getElementById('images-table'));
          // Setup filter after table is loaded
          setTimeout(initializeFilter, 100);
        }
      })
      .catch(error => {
        document.getElementById('images-table').innerHTML = '<div class="text-center py-8 text-red-600">Failed to load images</div>';
      });
  };

  // Setup filter on HTMX content updates
  document.body.addEventListener('htmx:afterSwap', function (evt) {
    if (evt.detail.target && (evt.detail.target.id === 'table-body' || evt.detail.target.id === 'images-table')) {
      setTimeout(initializeFilter, 100);
    }
  });

  // Initialize on page load
  loadImagesTable();
  setTimeout(initializeFilter, 500); // Setup filter after initial load
});