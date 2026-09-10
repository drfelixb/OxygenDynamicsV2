import unittest
import numpy as np
from verify_surge_expanded_peak import expand


class ExpandedPeakTests(unittest.TestCase):
    def fixture(self):
        y=np.full(160,100.);y[84]=130;y[99:120]=110
        return y,np.zeros(160,bool)

    def test_early_peak_unchanged_reference(self):
        y,b=self.fixture();r=expand(y,100,120,75,'resolved',b)
        self.assertEqual(r['ExpandedPeakFrame'],85);self.assertAlmostEqual(r['ExpandedSignedAmplitude'],.3)
        self.assertEqual(r['ReferenceMean'],100);self.assertEqual(r['AddedFrameCount'],25)

    def test_neighbor_and_missing_reject_without_fallback(self):
        y,b=self.fixture();b[90]=True;r=expand(y,100,120,75,'resolved',b)
        self.assertEqual(r['ExpandedStatus'],'added_interval_neighbor_overlap');self.assertTrue(np.isnan(r['ExpandedSignedAmplitude']))
        self.assertAlmostEqual(r['SignedRawAmplitude'],.1)
        b[90]=False;y[90]=np.nan
        self.assertEqual(expand(y,100,120,75,'resolved',b)['ExpandedStatus'],'nonfinite_added_interval')

    def test_reference_and_unresolved(self):
        y,b=self.fixture();b[60]=True
        self.assertEqual(expand(y,100,120,75,'resolved',b)['ExpandedStatus'],'overlapping_reference')
        self.assertFalse(expand(y,100,120,np.nan,'model_disagreement',b)['ExpandedArithmeticValid'])

    def test_negative_and_empty_addition(self):
        y,b=self.fixture();y[74:120]=90;r=expand(y,100,120,75,'resolved',b)
        self.assertAlmostEqual(r['ExpandedSignedAmplitude'],-.1);self.assertFalse(r['ExpandedPositiveEligible'])
        y,b=self.fixture();r=expand(y,100,120,100,'resolved',b)
        self.assertEqual(r['AddedFrameCount'],0);self.assertEqual(r['ExpandedSignedAmplitude'],r['SignedRawAmplitude'])


if __name__=='__main__':unittest.main()
