import unittest
import numpy as np
from verify_surge_amplitude_eligibility import assess


class EligibilityTests(unittest.TestCase):
    def evaluate(self,y,onset=41,status='resolved',blocked=None):
        return assess(y,51,60,onset,status,np.zeros(len(y),bool) if blocked is None else blocked)

    def test_signed_negative_and_zero(self):
        y=np.full(80,100.);y[50:60]=90
        r=self.evaluate(y)
        self.assertAlmostEqual(r['SignedRawAmplitude'],-.1)
        self.assertEqual(r['AmplitudeStatus'],'raw_direction_conflict')
        self.assertTrue(np.isnan(r['ProvisionalPositiveAmplitude']))
        self.assertEqual(self.evaluate(np.full(80,100.))['AmplitudeStatus'],'no_positive_raw_change')

    def test_positive_and_half_sensitivity(self):
        y=np.full(80,100.);y[20:30]=90;y[30:40]=110;y[50:60]=105
        r=self.evaluate(y)
        self.assertAlmostEqual(r['ProvisionalPositiveAmplitude'],.05)
        self.assertFalse(r['PositiveAcrossReferenceHalves'])
        self.assertEqual(r['NativePeakFrame'],51)

    def test_missing_and_excluded(self):
        y=np.full(80,100.);blocked=np.zeros(80,bool);blocked[25]=True
        self.assertEqual(self.evaluate(y,blocked=blocked)['AmplitudeStatus'],'overlapping_reference')
        self.assertEqual(self.evaluate(y,20)['AmplitudeStatus'],'incomplete_reference')
        self.assertEqual(self.evaluate(y,np.nan,'model_uncertainty')['AmplitudeStatus'],'onset_unresolved')
        self.assertEqual(self.evaluate(y,52)['AmplitudeStatus'],'invalid_onset')

    def test_nonfinite_and_nonpositive(self):
        y=np.full(80,100.);y[25]=np.nan
        self.assertEqual(self.evaluate(y)['AmplitudeStatus'],'nonfinite_reference')
        y[25]=100;y[55]=np.nan
        self.assertEqual(self.evaluate(y)['AmplitudeStatus'],'missing_native_signal')
        y[55]=100;y[20:40]=0
        self.assertEqual(self.evaluate(y)['AmplitudeStatus'],'nonpositive_reference')

    def test_sampling_and_gain(self):
        y=np.full(160,100.);y[100:120]=125;mask=np.zeros(160,bool)
        a=assess(y,101,120,81,'resolved',mask,2)
        b=assess(7*y,101,120,81,'resolved',mask,2)
        self.assertEqual(a['ReferenceStartFrame'],41)
        self.assertAlmostEqual(a['SignedRawAmplitude'],b['SignedRawAmplitude'])


if __name__=='__main__':
    unittest.main()
