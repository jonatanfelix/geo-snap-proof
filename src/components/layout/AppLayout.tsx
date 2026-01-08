import { SidebarProvider, SidebarTrigger } from '@/components/ui/sidebar';
import { AppSidebar } from './AppSidebar';
import { Menu } from 'lucide-react';

interface AppLayoutProps {
  children: React.ReactNode;
}

export function AppLayout({ children }: AppLayoutProps) {
  return (
    <SidebarProvider>
      <div className="min-h-screen flex w-full">
        <AppSidebar />
        <main className="flex-1 overflow-auto bg-background">
          {/* Mobile header with toggle */}
          <div className="sticky top-0 z-10 flex items-center gap-2 border-b border-border bg-background p-2 md:hidden">
            <SidebarTrigger className="p-2 hover:bg-muted rounded-md">
              <Menu className="h-5 w-5" />
            </SidebarTrigger>
            <span className="font-semibold">GeoAttend</span>
          </div>
          {children}
        </main>
      </div>
    </SidebarProvider>
  );
}
