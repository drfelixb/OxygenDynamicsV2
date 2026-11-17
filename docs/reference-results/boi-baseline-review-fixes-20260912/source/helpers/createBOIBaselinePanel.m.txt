function Panel=createBOIBaselinePanel(Parent,ReturnToEvent)
%CREATEBOIBASELINEPANEL Separate review diagnostic from saved measurements.
Grid=uigridlayout(Parent,[6 1]);Grid.RowHeight={32,56,68,'1x',180,76};
Heading=uigridlayout(Grid,[1 2]);Heading.Padding=[0 0 0 0];Heading.ColumnWidth={'1x',170};
Identity=uilabel(Heading,'Text','Select a saved event.','Interpreter','none','WordWrap','on');
Back=uibutton(Heading,'Text','View saved event','ButtonPushedFcn',@(~,~)ReturnToEvent());
Status=uilabel(Grid,'Text','Diagnostic unavailable until an event is selected.','Interpreter','none','WordWrap','on');
Amplitudes=uilabel(Grid,'Text','The saved measurement remains unchanged.','Interpreter','none','WordWrap','on');
Plots=uigridlayout(Grid,[1 2]);Plots.Padding=[0 0 0 0];BaselineAxes=uiaxes(Plots);ProjectionAxes=uiaxes(Plots);
Metrics=uitable(Grid,'ColumnName',{'Quantity','Value','Units / meaning'},'ColumnWidth',{280,150,'auto'}, ...
    'RowName',{},'Data',cell(0,3));
Details=uitextarea(Grid,'Editable','off','Value',{'A diagnostic is not an accepted correction or substrate estimate.'});
Panel=struct('Update',@update,'Identity',Identity,'Status',Status,'Amplitudes',Amplitudes, ...
    'BaselineAxes',BaselineAxes,'ProjectionAxes',ProjectionAxes,'Metrics',Metrics,'Details',Details,'Back',Back);
    function update(Data)
        D=Data.BaselineDiagnostic;F=Data.Frames;row=Data.Row;t=(F.Frame-row.StartFrame)/D.SampleF;
        Identity.Text=sprintf('%s | %s site %d, event %d | fixed footprint: %d pixels', ...
            row.RecordingID,row.EventType,row.SiteID,row.EventID,D.FootprintPixels);
        Status.Text=['DIAGNOSTIC ONLY — ' D.Message];
        if ~D.SavedMeasurementMatchesAudit,Status.Text=['DIAGNOSTIC ONLY — ' D.AuditAgreementMessage ' ' D.Message];end
        Amplitudes.Text=sprintf('Saved amplitude: %s   |   Audited mean-reference amplitude: %s   |   Line-reference diagnostic: %s\nReference sensitivity (line minus audited mean): %s\nSame %g required samples (%g s); %g clean samples available.', ...
            withUnit(100*row.StoredAmplitude,'%'),withUnit(100*D.AuditedAmplitudeFraction,'%'),withUnit(100*D.AmplitudeFraction,'%'),withUnit(D.DifferenceFromAuditedAmplitude_pp,' percentage points'),D.RequiredSamples,D.BaselineDurationSec,D.CleanSamples);
        metricNames={'Stored baseline';'Audited baseline';'Full baseline slope';'First-half slope';'Last-half slope';'Baseline coefficient of variation';'Baseline peak-to-trough';'Residual RMS around fitted line';'Descriptive R-squared';'Event extrapolation duration';'Minimum event reference';'Diagnostic signed integral';'Line minus saved amplitude'};
        values=[D.SavedBaseline;D.AuditedBaseline;D.SlopePercentPerSec;D.FirstHalfSlopePercentPerSec;D.LastHalfSlopePercentPerSec;D.CVPercent;D.PeakToTroughPercent;D.ResidualRMSPercent;D.DescriptiveR2;D.ExtrapolationDurationSec;D.MinimumEventReference;D.SignedAUC_sec;D.DifferenceFromSavedAmplitude_pp];
        units={'original-source units; saved result';'original-source units; source audit';'% of baseline / s';sprintf('%% / s; %d samples',D.FirstHalfSamples);sprintf('%% / s; %d samples',D.LastHalfSamples);'% of baseline';'% of baseline';'% of baseline';'descriptive; no acceptance threshold';'seconds';'original-source units';'fraction-seconds; review only';'percentage points; may include audit disagreement'};
        printed=cell(numel(values),1);for k=1:numel(values),printed{k}=char(number(values(k)));end
        Metrics.Data=[metricNames,printed,units];
        Details.Value=cellstr([string(D.AuditAgreementMessage);string(D.Limitations);string(D.NumericalInterpretation); ...
            "Line fitted only to the same clean baseline samples; red dashed extension uses no event samples."; ...
            "Unavailable values are not zero. R-squared is unavailable for a flat trace; half-slopes need at least two samples each."; ...
            "Calculation: "+string(D.MethodID)+". Export selected evidence includes diagnostic samples, method and implementation hashes."]);
        for which=1:2
            if which==1,ax=BaselineAxes;use=F.CleanBaseline;else,ax=ProjectionAxes;use=F.CleanBaseline|F.MeasurementWindow;end
            % Reset also clears hidden bound lines from the previously selected event.
            cla(ax,'reset');hold(ax,'on');h=gobjects(0);labels={};
            if any(use)
                h(end+1)=plot(ax,t(use),F.PreservedInputMean(use),'o-','Color',[.2 .35 .5],'MarkerSize',3);labels{end+1}='Original source';
                if isfinite(D.AuditedBaseline),h(end+1)=yline(ax,D.AuditedBaseline,'-','Color',[0 .55 .25],'Tag','BOIAuditedMeanReference');labels{end+1}='Audited mean reference';end
                if isfinite(D.SavedBaseline)&&~isequaln(D.SavedBaseline,D.AuditedBaseline)
                    h(end+1)=yline(ax,D.SavedBaseline,':','Color',[.6 .2 .65],'Tag','BOIStoredMeanReference');labels{end+1}='Stored baseline';
                end
                valid=use&isfinite(F.DiagnosticLinearReference);
                if any(valid),h(end+1)=plot(ax,t(valid),F.DiagnosticLinearReference(valid),'r--','LineWidth',1.5,'Tag','BOIDiagnosticReference');labels{end+1}='Diagnostic line';end
                if which==2
                    xline(ax,0,'k--','HandleVisibility','off','Tag','BOIDiagnosticMeasurementBound');
                    xline(ax,(row.EndFrame-row.StartFrame+1)/D.SampleF,'k--','HandleVisibility','off','Tag','BOIDiagnosticMeasurementBound');
                    xline(ax,(row.DetectedStartFrame-row.StartFrame)/D.SampleF,'b:','HandleVisibility','off','Tag','BOIDiagnosticNativeBound');
                    xline(ax,(row.DetectedEndFrame-row.StartFrame+1)/D.SampleF,'b:','HandleVisibility','off','Tag','BOIDiagnosticNativeBound');
                end
                limits=[min(t(use)),max(t(use))];
                if which==2
                    bounds=([row.StartFrame,row.EndFrame+1,row.DetectedStartFrame,row.DetectedEndFrame+1]-row.StartFrame)/D.SampleF;
                    limits=[min([limits,bounds]),max([limits,bounds])];
                end
                xlim(ax,limits+[-.5,.5]/D.SampleF);
                legend(ax,h,labels,'Location','best');
            else
                legend(ax,'off');
                axis(ax,'off');text(ax,.5,.5,'No clean baseline samples','Units','normalized','HorizontalAlignment','center');
            end
            xlabel(ax,'Seconds relative to measurement start');ylabel(ax,'Preserved input (a.u.)');grid(ax,'on');hold(ax,'off');
        end
        title(BaselineAxes,sprintf('Clean baseline: %g / %g samples',D.CleanSamples,D.RequiredSamples));
        title(ProjectionAxes,{'Baseline and measurement window','Black dashed bounds; blue dotted native bounds'});
    end
end
function text=number(value)
text="unavailable";if isfinite(value),text=string(sprintf('%.6g',value));end
end
function text=withUnit(value,unit)
text=number(value);if isfinite(value),text=text+string(unit);end
end
