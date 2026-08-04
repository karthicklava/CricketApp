import React from 'react';

export default function AdminDashboard() {
  return (
    <div style={{ fontFamily: 'system-ui, sans-serif', backgroundColor: '#F8F9FA', minHeight: '100vh', padding: '24px' }}>
      {/* Top Header */}
      <header style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', backgroundColor: '#0F5132', color: '#FFF', padding: '16px 24px', borderRadius: '12px', marginBottom: '24px' }}>
        <div>
          <h1 style={{ margin: 0, fontSize: '24px', fontWeight: 'bold' }}>🏏 Cricket Platform Administration</h1>
          <p style={{ margin: '4px 0 0', opacity: 0.8, fontSize: '14px' }}>Live Matches, Tournaments & Offline Scorer Monitor</p>
        </div>
        <div style={{ display: 'flex', gap: '12px' }}>
          <button style={{ backgroundColor: '#198754', color: '#FFF', border: 'none', padding: '10px 18px', borderRadius: '8px', fontWeight: 'bold', cursor: 'pointer' }}>+ Create Tournament</button>
          <button style={{ backgroundColor: '#20C997', color: '#FFF', border: 'none', padding: '10px 18px', borderRadius: '8px', fontWeight: 'bold', cursor: 'pointer' }}>+ Schedule Match</button>
        </div>
      </header>

      {/* Metric Cards */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))', gap: '16px', marginBottom: '24px' }}>
        <div style={{ backgroundColor: '#FFF', padding: '20px', borderRadius: '12px', boxShadow: '0 2px 4px rgba(0,0,0,0.05)' }}>
          <span style={{ color: '#6C757D', fontSize: '13px', fontWeight: '600' }}>LIVE MATCHES</span>
          <h2 style={{ margin: '8px 0 0', fontSize: '32px', color: '#198754' }}>3 Active</h2>
        </div>
        <div style={{ backgroundColor: '#FFF', padding: '20px', borderRadius: '12px', boxShadow: '0 2px 4px rgba(0,0,0,0.05)' }}>
          <span style={{ color: '#6C757D', fontSize: '13px', fontWeight: '600' }}>REGISTERED TEAMS</span>
          <h2 style={{ margin: '8px 0 0', fontSize: '32px', color: '#212529' }}>16 Teams</h2>
        </div>
        <div style={{ backgroundColor: '#FFF', padding: '20px', borderRadius: '12px', boxShadow: '0 2px 4px rgba(0,0,0,0.05)' }}>
          <span style={{ color: '#6C757D', fontSize: '13px', fontWeight: '600' }}>OFFLINE SCORERS ACTIVE</span>
          <h2 style={{ margin: '8px 0 0', fontSize: '32px', color: '#FD7E14' }}>4 Scorers</h2>
        </div>
        <div style={{ backgroundColor: '#FFF', padding: '20px', borderRadius: '12px', boxShadow: '0 2px 4px rgba(0,0,0,0.05)' }}>
          <span style={{ color: '#6C757D', fontSize: '13px', fontWeight: '600' }}>TOTAL DELIVERIES SYNCED</span>
          <h2 style={{ margin: '8px 0 0', fontSize: '32px', color: '#0D6EFD' }}>1,420 Balls</h2>
        </div>
      </div>

      {/* Live Match Feed Section */}
      <div style={{ backgroundColor: '#FFF', padding: '24px', borderRadius: '12px', boxShadow: '0 2px 4px rgba(0,0,0,0.05)' }}>
        <h2 style={{ marginTop: 0, fontSize: '18px', color: '#212529' }}>Live Match Scorecards & Sync Health</h2>
        
        <div style={{ border: '1px solid #E9ECEF', borderRadius: '8px', padding: '16px', marginTop: '16px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <div>
            <span style={{ backgroundColor: '#D1E7DD', color: '#0F5132', padding: '4px 8px', borderRadius: '4px', fontSize: '12px', fontWeight: 'bold' }}>LIVE - INNINGS 2</span>
            <h3 style={{ margin: '8px 0 4px', fontSize: '18px' }}>India vs Australia (T20 Tournament Final)</h3>
            <p style={{ margin: 0, color: '#6C757D', fontSize: '14px' }}>IND: 184/5 (20.0 ov) | AUS: 142/3 (14.2 ov) - Target 185</p>
          </div>
          <div style={{ textAlign: 'right' }}>
            <span style={{ color: '#198754', fontWeight: 'bold', fontSize: '14px' }}>🟢 Device Syncing (0 pending)</span>
            <br />
            <button style={{ marginTop: '8px', backgroundColor: '#0F5132', color: '#FFF', border: 'none', padding: '8px 14px', borderRadius: '6px', cursor: 'pointer' }}>View Spectator Web Scorecard</button>
          </div>
        </div>
      </div>
    </div>
  );
}
