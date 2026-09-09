"""Known-answer checks for the independent paired-source amplitude verifier."""
import unittest
import numpy as np
from verify_surge_amplitude_support import metrics, same


class AmplitudeVerifierTests(unittest.TestCase):
    def evaluate(self,x,p,n=None,clean=None):
        if n is None:n=np.zeros(40)
        if clean is None:clean=np.arange(4,24)
        return metrics(x,x+p+n,p,n,np.arange(24,30),np.arange(4,24),clean,np.arange(20,30))

    def test_known_rising_tail(self):
        p=np.zeros(40);p[20:30]=20
        r,status=self.evaluate(np.full(40,100.),p)
        self.assertEqual(status,'valid');self.assertAlmostEqual(r['StrictMeasuredPeakFraction'],16/104)
        self.assertAlmostEqual(r['UnscreenedBaselineImposedFraction'],.04)
        self.assertAlmostEqual(r['UnscreenedCounterfactualPeakFraction'],.2)

    def test_negative_baseline_contribution(self):
        p=np.zeros(40);p[24:30]=20;n=np.zeros(40);n[20:24]=-20
        r,_=self.evaluate(np.full(40,100.),p,n)
        self.assertAlmostEqual(r['StrictMeasuredPeakFraction'],.25)
        self.assertAlmostEqual(r['UnscreenedBaselineNegativeFraction'],-.04)

    def test_missingness_is_not_repaired(self):
        p=np.zeros(40);p[24:30]=20
        r,status=self.evaluate(np.full(40,100.),p,clean=np.arange(4,23))
        self.assertEqual(status,'insufficient_clean_prebaseline')
        self.assertTrue(np.isnan(r['StrictMeasuredPeakFraction']))
        self.assertAlmostEqual(r['UnscreenedObservedPeakFraction'],.2)

    def test_extrema_are_not_added(self):
        x=np.full(40,100.);x[24]=130;p=np.zeros(40);p[25]=40
        r,_=self.evaluate(x,p)
        self.assertEqual(r['NativePeakFrame'],26)
        self.assertEqual(r['UnscreenedBackgroundAtObservedPeak'],0)
        self.assertAlmostEqual(r['UnscreenedCounterfactualPeakFraction'],.4)
        self.assertAlmostEqual(r['UnscreenedSourcePeakFraction'],.3)

    def test_nonpositive_baseline(self):
        r,status=self.evaluate(np.zeros(40),np.zeros(40))
        self.assertEqual(status,'nonpositive_baseline_or_missing_event_signal')
        self.assertTrue(np.isnan(r['StrictMeasuredPeakFraction']))

    def test_truncated_baseline(self):
        x=np.full(40,100.);z=np.zeros(40)
        r,status=metrics(x,x,z,z,np.arange(4,10),np.arange(4),np.arange(4),np.arange(20,30))
        self.assertEqual(status,'insufficient_clean_prebaseline')
        self.assertTrue(np.isnan(r['UnscreenedObservedPeakFraction']))
        self.assertTrue(np.isnan(r['PeakPositiveAppliedInNativeIntersection']))

    def test_corruption_rejected_with_optimization(self):
        same('NaN',np.nan,'missing')
        with self.assertRaises(ValueError):same('.2',.4,'corrupt')
        with self.assertRaises(ValueError):same('NaN',0,'missing versus zero')


if __name__=='__main__':unittest.main()
