function Result = analyzeHypoxiaAmyloidPair(HypoxiaStack,AmyloidImage,Options)
%ANALYZEHYPOXIAAMYLOIDPAIR Pure spatial analysis of hypoxia and amyloid arrays.
%
% Result = analyzeHypoxiaAmyloidPair(HypoxiaStack,AmyloidImage,Options)
% accepts a binary hypoxia stack and a registered 2-D amyloid image. The
% function performs no file access, plotting, or output writing.

if nargin<3 || isempty(Options)
    Options = struct();
end
Options = applyDefaults(Options);

if ndims(HypoxiaStack)~=3 || size(HypoxiaStack,3)<1
    error('HypoxiaAmyloid:InvalidHypoxiaStack', ...
        'HypoxiaStack must be a height-by-width-by-frame array.');
end

AmyloidImage = double(AmyloidImage);
if ndims(AmyloidImage)==3
    AmyloidImage = mean(AmyloidImage,3);
end
if ~isequal(size(AmyloidImage),[size(HypoxiaStack,1),size(HypoxiaStack,2)])
    error('HypoxiaAmyloid:DimensionMismatch', ...
        'Hypoxia and amyloid image dimensions must match.');
end

TissueMask = Options.TissueMask;
if isempty(TissueMask)
    TissueMask = true(size(AmyloidImage));
elseif ~isequal(size(TissueMask),size(AmyloidImage))
    error('HypoxiaAmyloid:TissueMaskDimensionMismatch', ...
        'TissueMask dimensions must match the image dimensions.');
else
    TissueMask = logical(TissueMask);
end

PixelSize = Options.PixelSizeMicrometers;
RegionSigmaPixels = Options.RegionSigmaMicrometers/PixelSize;
CoarseSigmaPixels = Options.CoarseSigmaMicrometers/PixelSize;

HypoxiaFrequency = mean(HypoxiaStack>0,3);
HypoxiaFrequency(~TissueMask) = 0;
HypoxiaPercent = 100*HypoxiaFrequency;
HypoxiaRelative = normalize01(HypoxiaFrequency,TissueMask);

FlatField = imgaussfilt(AmyloidImage,CoarseSigmaPixels);
AmyloidCorrected = AmyloidImage./max(FlatField,eps);
AmyloidCorrected(~TissueMask) = 0;
AmyloidCorrected = normalizeByMaximum(AmyloidCorrected,TissueMask);

ResolvedThreshold = Options.AmyloidThreshold;
if isnan(ResolvedThreshold)
    TissueValues = AmyloidCorrected(TissueMask);
    AmyloidMedian = median(TissueValues,'omitnan');
    RobustSigma = 1.4826*median(abs(TissueValues-AmyloidMedian),'omitnan');
    ResolvedThreshold = AmyloidMedian+4*RobustSigma;
    MaxValue = max(TissueValues,[],'omitnan');
    if isfinite(MaxValue)
        ResolvedThreshold = min(ResolvedThreshold,max(MaxValue-eps,0));
    end
end

AmyloidRelative = max(AmyloidCorrected-ResolvedThreshold,0);
AmyloidRelative = normalizeByMaximum(AmyloidRelative,TissueMask);
HypoxiaSmoothed = imgaussfilt(HypoxiaRelative,RegionSigmaPixels);
HypoxiaMask = HypoxiaSmoothed>Options.HypoxiaThreshold & TissueMask;
AmyloidMask = bwareaopen(AmyloidCorrected>ResolvedThreshold & TissueMask, ...
    Options.MinimumPlaqueAreaPixels);

PropertyNames = {'Centroid','Area','MaxIntensity','MeanIntensity', ...
    'EquivDiameter','Perimeter','Eccentricity','PixelIdxList'};
HypoxiaProps = regionprops(HypoxiaMask,HypoxiaSmoothed,PropertyNames);
AmyloidProps = regionprops(AmyloidMask,AmyloidCorrected,PropertyNames);

HypoxiaAreaMap = imgaussfilt(HypoxiaRelative,CoarseSigmaPixels);
AmyloidAreaMap = imgaussfilt(AmyloidRelative,CoarseSigmaPixels);
HypoxiaAreaMap(~TissueMask) = 0;
AmyloidAreaMap(~TissueMask) = 0;
[ObservedCorrelation,ObservedKL] = compareSpatialMaps(HypoxiaAreaMap,AmyloidAreaMap,TissueMask);
ObservedOverlap = overlapFraction(AmyloidMask,HypoxiaMask,TissueMask);

rng(Options.RandomSeed);
NullCorrelation = nan(Options.NumPermutations,1);
NullKL = nan(Options.NumPermutations,1);
NullOverlap = nan(Options.NumPermutations,1);
NullShifts = nan(Options.NumPermutations,2);
ImageSize = size(AmyloidImage);
for PermutationIdx = 1:Options.NumPermutations
    Shift = [randi(ImageSize(1))-1,randi(ImageSize(2))-1];
    NullShifts(PermutationIdx,:) = Shift;
    ShiftedMap = circshift(AmyloidAreaMap,Shift);
    ShiftedMask = circshift(AmyloidMask,Shift);
    [NullCorrelation(PermutationIdx),NullKL(PermutationIdx)] = ...
        compareSpatialMaps(HypoxiaAreaMap,ShiftedMap,TissueMask);
    NullOverlap(PermutationIdx) = overlapFraction(ShiftedMask,HypoxiaMask,TissueMask);
end

[CorrelationP,KlP,ExpectedOverlap,OverlapEnrichment,OverlapP] = ...
    summarizeNulls(ObservedCorrelation,ObservedKL,ObservedOverlap, ...
    NullCorrelation,NullKL,NullOverlap);

FineCorrelationMap = circularCorrelationMap(HypoxiaRelative,AmyloidRelative);
CoarseCorrelationMap = circularCorrelationMap(HypoxiaAreaMap,AmyloidAreaMap);
[CoarsePeak,CoarseOffset] = correlationPeak(CoarseCorrelationMap);

Result = struct();
Result.hypoxia_frequency = HypoxiaFrequency;
Result.hypoxia_percent = HypoxiaPercent;
Result.amyloid_corrected = AmyloidCorrected;
Result.amyloid_relative = AmyloidRelative;
Result.hypoxia_mask = HypoxiaMask;
Result.amyloid_mask = AmyloidMask;
Result.hp_props = HypoxiaProps;
Result.ab_props = AmyloidProps;
Result.observed_correlation = ObservedCorrelation;
Result.correlation_p_value = CorrelationP;
Result.null_correlation = NullCorrelation;
Result.observed_kl = ObservedKL;
Result.kl_p_value = KlP;
Result.null_kl = NullKL;
Result.observed_overlap_fraction = ObservedOverlap;
Result.expected_overlap_fraction = ExpectedOverlap;
Result.overlap_enrichment = OverlapEnrichment;
Result.overlap_p_value = OverlapP;
Result.null_overlap_fraction = NullOverlap;
Result.null_shifts_pixels = NullShifts;
Result.fine_correlation_map = FineCorrelationMap;
Result.coarse_correlation_map = CoarseCorrelationMap;
Result.coarse_correlation_peak = CoarsePeak;
Result.coarse_correlation_offset_pixels = CoarseOffset;
Result.coarse_correlation_offset_micrometers = CoarseOffset*PixelSize;
Result.pixel_size_micrometers = PixelSize;
Options.ResolvedAmyloidThreshold = ResolvedThreshold;
Options.RegionSigmaPixels = RegionSigmaPixels;
Options.CoarseSigmaPixels = CoarseSigmaPixels;
Result.analysis_options = Options;
end

function Options = applyDefaults(Options)

Defaults = struct();
Defaults.PixelSizeMicrometers = 4.86;
Defaults.AmyloidThreshold = NaN;
Defaults.HypoxiaThreshold = 0.07;
Defaults.MinimumPlaqueAreaPixels = 3;
Defaults.RegionSigmaMicrometers = 9.72;
Defaults.CoarseSigmaMicrometers = 243;
Defaults.NumPermutations = 1000;
Defaults.RandomSeed = 1;
Defaults.TissueMask = [];

Names = fieldnames(Defaults);
for Idx = 1:numel(Names)
    Name = Names{Idx};
    if ~isfield(Options,Name) || isempty(Options.(Name))
        Options.(Name) = Defaults.(Name);
    end
end

if ~isscalar(Options.PixelSizeMicrometers) || Options.PixelSizeMicrometers<=0
    error('HypoxiaAmyloid:InvalidPixelSize','PixelSizeMicrometers must be positive.');
end
if Options.NumPermutations<0 || fix(Options.NumPermutations)~=Options.NumPermutations
    error('HypoxiaAmyloid:InvalidPermutationCount', ...
        'NumPermutations must be a nonnegative integer.');
end
end

function Output = normalize01(Input,Mask)

Values = Input(Mask);
Minimum = min(Values,[],'omitnan');
Maximum = max(Values,[],'omitnan');
Output = zeros(size(Input));
if isfinite(Minimum) && isfinite(Maximum) && Maximum>Minimum
    Output(Mask) = (Input(Mask)-Minimum)./(Maximum-Minimum);
end
end

function Output = normalizeByMaximum(Input,Mask)

Maximum = max(Input(Mask),[],'omitnan');
Output = zeros(size(Input));
if isfinite(Maximum) && Maximum>0
    Output(Mask) = Input(Mask)./Maximum;
end
end

function [Correlation,Divergence] = compareSpatialMaps(First,Second,Mask)

X = First(Mask);
Y = Second(Mask);
Valid = isfinite(X) & isfinite(Y);
X = X(Valid);
Y = Y(Valid);
if numel(X)<3 || std(X)==0 || std(Y)==0
    Correlation = NaN;
else
    Matrix = corrcoef(X,Y);
    Correlation = Matrix(1,2);
end
Divergence = klDivergence(X,Y);
end

function Divergence = klDivergence(First,Second)

First = max(First,0);
Second = max(Second,0);
FirstSum = sum(First,'omitnan');
SecondSum = sum(Second,'omitnan');
if FirstSum<=0 || SecondSum<=0
    Divergence = NaN;
    return
end
First = First/FirstSum;
Second = Second/SecondSum;
Mask = First>0 & isfinite(First) & isfinite(Second);
Divergence = sum(First(Mask).*log(First(Mask)./max(Second(Mask),1e-12)),'omitnan');
end

function Fraction = overlapFraction(TargetMask,ReferenceMask,TissueMask)

TargetMask = TargetMask & TissueMask;
TargetCount = nnz(TargetMask);
if TargetCount==0
    Fraction = NaN;
else
    Fraction = nnz(TargetMask & ReferenceMask)/TargetCount;
end
end

function [CorrelationP,KlP,ExpectedOverlap,Enrichment,OverlapP] = ...
    summarizeNulls(ObservedCorrelation,ObservedKL,ObservedOverlap,NullCorrelation,NullKL,NullOverlap)

if isempty(NullCorrelation)
    CorrelationP = NaN;
    KlP = NaN;
    ExpectedOverlap = NaN;
    Enrichment = NaN;
    OverlapP = NaN;
    return
end

CorrelationP = plusOneP(abs(NullCorrelation),abs(ObservedCorrelation),'upper');
KlP = plusOneP(NullKL,ObservedKL,'lower');
ExpectedOverlap = mean(NullOverlap,'omitnan');
if ~isfinite(ObservedOverlap) || ~isfinite(ExpectedOverlap) || ExpectedOverlap<=0
    Enrichment = NaN;
    OverlapP = NaN;
else
    Enrichment = ObservedOverlap/ExpectedOverlap;
    OverlapP = plusOneP(NullOverlap,ObservedOverlap,'upper');
end
end

function P = plusOneP(NullValues,Observed,Direction)

Valid = isfinite(NullValues);
if ~isfinite(Observed) || ~any(Valid)
    P = NaN;
elseif strcmp(Direction,'lower')
    P = (1+sum(NullValues(Valid)<=Observed))/(nnz(Valid)+1);
else
    P = (1+sum(NullValues(Valid)>=Observed))/(nnz(Valid)+1);
end
end

function Map = circularCorrelationMap(First,Second)

First = zscoreImage(First);
Second = zscoreImage(Second);
if any(~isfinite(First(:))) || any(~isfinite(Second(:)))
    Map = nan(size(First));
    return
end
Map = real(ifft2(fft2(First).*conj(fft2(Second))))/numel(First);
Map = fftshift(Map);
end

function Output = zscoreImage(Input)

Sigma = std(Input(:));
if Sigma>0
    Output = (Input-mean(Input(:)))/Sigma;
else
    Output = nan(size(Input));
end
end

function [Peak,Offset] = correlationPeak(Map)

if all(isnan(Map(:)))
    Peak = NaN;
    Offset = [NaN NaN];
    return
end
[Peak,Index] = max(Map(:),[],'omitnan');
[Row,Column] = ind2sub(size(Map),Index);
Center = floor(size(Map)/2)+1;
Offset = [Column-Center(2),Row-Center(1)];
end
