

export default ({
  icon, title, onMouseDown, active,
}) => (
  <span title={title} className={`bar-button ${active ? 'active' : ''}`} onMouseDown={onMouseDown}>
    <i className={`fas fa-text-${icon}`}></i>
  </span>
);
