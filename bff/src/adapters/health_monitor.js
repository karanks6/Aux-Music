'use strict';

/**
 * Source health monitor for the BFF.
 * Runs a lightweight health check on each adapter every 5 minutes.
 * Degraded sources are skipped in fan-out requests.
 */
class SourceHealthMonitor {
  constructor(adapters) {
    this.adapters = adapters;
    this.statuses = {};
    this.interval = null;

    // Initialize all as healthy
    for (const a of adapters) {
      this.statuses[a.sourceId] = {
        sourceId: a.sourceId,
        displayName: a.displayName,
        isHealthy: true,
        checkedAt: new Date().toISOString(),
        latencyMs: null,
        error: null,
      };
    }
  }

  start() {
    // Run immediately, then every 5 minutes
    this._runChecks();
    this.interval = setInterval(() => this._runChecks(), 5 * 60 * 1000);
  }

  stop() {
    if (this.interval) clearInterval(this.interval);
  }

  isHealthy(sourceId) {
    return this.statuses[sourceId]?.isHealthy ?? false;
  }

  getStatuses() {
    return Object.values(this.statuses);
  }

  async _runChecks() {
    for (const adapter of this.adapters) {
      if (!adapter.isEnabled) {
        this.statuses[adapter.sourceId] = {
          sourceId: adapter.sourceId,
          displayName: adapter.displayName,
          isHealthy: false,
          checkedAt: new Date().toISOString(),
          latencyMs: null,
          error: 'Adapter is disabled (feature flag)',
        };
        continue;
      }

      const start = Date.now();
      try {
        await Promise.race([
          adapter.healthCheck(),
          new Promise((_, reject) =>
            setTimeout(() => reject(new Error('Health check timeout')), 5000)
          ),
        ]);
        this.statuses[adapter.sourceId] = {
          sourceId: adapter.sourceId,
          displayName: adapter.displayName,
          isHealthy: true,
          checkedAt: new Date().toISOString(),
          latencyMs: Date.now() - start,
          error: null,
        };
      } catch (err) {
        this.statuses[adapter.sourceId] = {
          sourceId: adapter.sourceId,
          displayName: adapter.displayName,
          isHealthy: false,
          checkedAt: new Date().toISOString(),
          latencyMs: Date.now() - start,
          error: err.message,
        };
        console.error(`[HealthMonitor] ${adapter.sourceId} degraded:`, err.message);
      }
    }
  }
}

module.exports = { SourceHealthMonitor };
