import { Navigate } from 'react-router-dom';

// Redirect /clock to dashboard where the clock in/out functionality is located
const Clock = () => {
  return <Navigate to="/" replace />;
};

export default Clock;
