

export default ({
  icon, title, onMouseDown, active, enable = true
}) => (
  <span title={title} className={`bar-button ${active ? 'active' : ''} ${!enable ? 'disabled' : ''}`} onMouseDown={(event) => {
    if (enable) {
      return onMouseDown(event)
    }
    return false;
  }}>
    <i className={`fas fa-text-${icon}`}></i>
  </span>
);
