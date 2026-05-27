function [TableOxygenSinks,TableOxygenSurges,AdditionalOxySinkMetrics,AdditionalOxySurgeMetrics] = ...
    augmentStatsOxygenMetricTables(TableOxygenSinks,TableOxygenSurges)
%AUGMENTSTATSOXYGENMETRICTABLES Add derived sink/surge metrics to stats tables.

AdditionalOxySinkMetrics = createAdditionalOxygenSinkMetrics(TableOxygenSinks);
AdditionalOxySurgeMetrics = createAdditionalOxygenSurgeMetrics(TableOxygenSurges);

TableOxygenSinks = [TableOxygenSinks,AdditionalOxySinkMetrics];
TableOxygenSurges = [TableOxygenSurges,AdditionalOxySurgeMetrics];

end
