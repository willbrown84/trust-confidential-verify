import Header from "@/components/Header";
import SettingsPanel from "@/components/SettingsPanel";

const Settings = () => {
  return (
    <div className="min-h-screen bg-background">
      <Header />
      <main className="container mx-auto px-6 py-8">
        <div className="max-w-4xl mx-auto">
          <div className="mb-8">
            <h1 className="text-3xl font-bold mb-4 bg-gradient-to-r from-primary to-trust-primary bg-clip-text text-transparent">
              Settings
            </h1>
            <p className="text-muted-foreground text-lg">
              Configure your verification preferences and security settings
            </p>
          </div>
          <SettingsPanel />
        </div>
      </main>
    </div>
  );
};

export default Settings;