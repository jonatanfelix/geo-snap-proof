# GeoAttend - Smart Geolocation Attendance System

GeoAttend is a comprehensive attendance management solution designed for modern workforce tracking. It combines precise geolocation verification with robust administrative tools to manage office and field employees efficiently. Built with anti-fraud mechanisms to ensure authentic attendance records.

## 🚀 Key Features

### 📱 For Employees
- **Smart Clock-In/Out**: 
  - **Office Mode**: Validates location within a specific radius of the office.
  - **Field Mode**: Records location for field duty staff.
- **Live Location Verification**: Anti-fake GPS measures to ensure data integrity.
- **Personal Dashboard**: View daily stats, attendance history, and working hours.
- **Leave Management**: Request leave (sick, permit, annual leave) directly from the app.

### 🛠 For Admins
- **Interactive Dashboard**: Real-time overview of daily attendance, late arrivals, and on-leave staff.
- **Employee Management**: 
  - Manage employee profiles, departments, and shifts.
  - Assign specific roles (Admin, Developer, Employee).
- **Payroll Automation**: 
  - Auto-calculate working hours, overtime, and late deductions.
  - Customizable penalty rates and standard work hours.
  - Export payroll data to Excel (`.xlsx`).
- **Comprehensive Reporting**: 
  - Daily, monthly, and custom date range reports.
  - Detailed audit logs for system activities.
- **Company Settings**: Configure office location (lat/long), radius, work hours, and late penalties.

## 💻 Tech Stack

- **Frontend**: [React](https://react.dev/) + [TypeScript](https://www.typescriptlang.org/) + [Vite](https://vitejs.dev/)
- **Styling**: [Tailwind CSS](https://tailwindcss.com/) + [Shadcn UI](https://ui.shadcn.com/)
- **Maps**: [Leaflet](https://leafletjs.com/) + [React-Leaflet](https://react-leaflet.js.org/)
- **Backend & Database**: [Supabase](https://supabase.com/) (PostgreSQL, Auth, Edge Functions)
- **Data Fetching**: [TanStack Query](https://tanstack.com/query/latest)
- **Utilities**: `date-fns` (Date manipulation), `xlsx` (Excel export)

## 🛠️ Installation & Setup

### Prerequisites
- Node.js (v18+ recommended)
- NPM or Yarn
- A Supabase project

### 1. Clone the Repository
```bash
git clone https://github.com/jonatanfelix/geo-snap-proof.git
cd geo-snap-proof
```

### 2. Install Dependencies
```bash
npm install
```

### 3. Environment Configuration
Create a `.env` file in the root directory and add your Supabase credentials:

```env
VITE_SUPABASE_URL=your_supabase_url
VITE_SUPABASE_PUBLISHABLE_KEY=your_supabase_anon_key
```

### 4. Run Development Server
```bash
npm run dev
```
The app will be available at `https://localhost:8081` (Note: HTTPS is enabled for geolocation testing).

## 🗄️ Database Setup (Supabase)

This project uses Supabase for the backend. Ensure you have the necessary tables created.
Migration files can be found in `supabase/migrations`.

Run migrations locally (if using Supabase CLI):
```bash
npx supabase migration up
```

## 🚀 Deployment

The project is optimized for deployment on Vercel or Netlify.

1. **Build the project:**
   ```bash
   npm run build
   ```
2. **Deploy the `dist` folder.**

## 🤝 Contributing

Contributions are welcome! Please fork the repository and create a pull request.

## 📝 License

[MIT](LICENSE)
