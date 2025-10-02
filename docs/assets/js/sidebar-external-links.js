// Inject external links into sidebar
document.addEventListener('DOMContentLoaded', function() {
  // Find the sidebar navigation
  const sidebar = document.querySelector('.site-nav');
  if (!sidebar) return;

  // Create external links section
  const externalLinksSection = document.createElement('div');
  externalLinksSection.className = 'sidebar-external-links';
  
  externalLinksSection.innerHTML = `
    <h3 class="sidebar-section-title">External Links</h3>
    <ul class="sidebar-external-list">
      <li class="sidebar-external-item">
        <a href="https://github.com/nyaggah/opaque_id" class="sidebar-external-link" target="_blank" rel="noopener">
          <span class="sidebar-external-icon">📁</span>
          GitHub
        </a>
      </li>
      <li class="sidebar-external-item">
        <a href="https://rubygems.org/gems/opaque_id" class="sidebar-external-link" target="_blank" rel="noopener">
          <span class="sidebar-external-icon">💎</span>
          RubyGems
        </a>
      </li>
      <li class="sidebar-external-item">
        <a href="https://github.com/nyaggah/opaque_id/issues" class="sidebar-external-link" target="_blank" rel="noopener">
          <span class="sidebar-external-icon">🐛</span>
          Issues
        </a>
      </li>
      <li class="sidebar-external-item">
        <a href="https://github.com/nyaggah/opaque_id/releases" class="sidebar-external-link" target="_blank" rel="noopener">
          <span class="sidebar-external-icon">🚀</span>
          Releases
        </a>
      </li>
    </ul>
  `;

  // Insert at the beginning of the sidebar
  sidebar.parentNode.insertBefore(externalLinksSection, sidebar);
});
